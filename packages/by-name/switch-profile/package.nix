{ lib, writers, skim, clj-ask }: writers.writeBabashkaBin "switch-profile" {
  makeWrapperArgs = [
    "--prefix" "PATH" ":" "${lib.makeBinPath [skim]}"
  ];
} /* clojure */ ''
#!/usr/bin/env bb

(ns profiles
  (:require [babashka.classpath :as cp]
            [babashka.fs :as fs]
            [babashka.process :refer [shell]]
            [clojure.string :refer [trim join starts-with?]]))

(cp/add-classpath "${clj-ask}/bin")
(require '[ask :refer [ask?]])

(def profile-dirs
  (map str ["/nix/var/nix/profiles/"
            (fs/expand-home "~/.local/state/nix/profiles/")]))

(defn file-starts-with? [prefix]
  (fn [path] (starts-with? (fs/file-name path) prefix)))

(def system? (file-starts-with? "system-"))
(def profile? (file-starts-with? "home-manager-"))

(defn system-or-profile? [path]
  (or
   (system? path)
   (profile? path)))

(def profiles
  (map str (-> profile-dirs
               (fs/list-dirs system-or-profile?)
               flatten
               sort
               distinct)))

(def chosen-profile
  (->
    (shell {:in (join "\n" profiles) :out :string} "sk")
    :out
    trim
    fs/path))

(cond
  (system? chosen-profile)
  (when 
    (ask? (str "Make system " (fs/file-name chosen-profile) " boot default?") false)
    (shell {} "sudo " (str chosen-profile "/bin/switch-to-configuration") "boot"))

  (profile? chosen-profile)
  (when 
    (ask? (str "Switch to home " (fs/file-name chosen-profile) " ?") true)
    (shell {} (str chosen-profile "/activate")))
  :else (-> "Unreachable" Exception. throw))
''
