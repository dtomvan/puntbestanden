#!/usr/bin/env bb

(let [f (if-let 
          [path (-> *command-line-args* first)]
          path
          (System/getenv "PWD"))]
  (->>
    f
    java.io.File.
    .list
    (map println)
    doall))
