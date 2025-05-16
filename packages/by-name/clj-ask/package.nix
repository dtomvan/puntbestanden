{ writers }:
writers.writeBabashkaBin "ask.clj" { } # clojure
  ''
    (ns ask
      (:require [clojure.string :refer [join lower-case]]))

    (def console (System/console))

    (defn make-yes-or-no [default]
      (str "[" (if default "Y" "y") "/" (if default "n" "N") "]"))

    (defn yes-or-no? [answer default]
      (let [answer (lower-case answer)]
        (cond
          (= answer "y") true
          (= answer "n") false
          :else default)))

    (defn ask? [question default]
      (yes-or-no?
       (.readln console
                (str question "? " (make-yes-or-no default) " > "))
       default))

    (defn -main [& args]
      (let [q (join " " args)
            q (if (empty? q) "Yes or no" q)]
        (System/exit
         (if (ask? q false)
           0
           1))))

    (when (= *file* (System/getProperty "babashka.file"))
      (apply -main *command-line-args*))
  ''
