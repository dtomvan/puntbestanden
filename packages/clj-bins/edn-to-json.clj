#!/usr/bin/env bb

(ns edn-to-json
  (:require [cheshire.core :as json]
            [clojure.edn :as edn]))

(let [contents (if-let 
          [path (-> *command-line-args* first)]
          (slurp (java.io.File. path))
          (slurp System/in))]
  (-> 
    contents
    edn/read-string
    json/generate-string
    print))
