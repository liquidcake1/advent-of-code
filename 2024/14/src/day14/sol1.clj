(ns day14.sol1
  (:gen-class))
(require '[clojure.string :as str])
(defn test [a] (list a))
(defn parse-coord [s]
  (for [c (str/split (second (str/split s #"=")) #",")] (Integer/parseInt c)))
(defn parse-input [line]
  (let [pandv (str/split line #" ")]
    [(parse-coord (first pandv))
     (parse-coord (second pandv))]))
(defn add-wrap [co]
  (let [x (+ (first co) (second co))
        bounded (mod x (last co))]
    bounded))
(defn step [robot gridsize]
  (let [coord (first robot)
        velocity (second robot)]
    [(for [x (map vector coord velocity gridsize)] (add-wrap x)) velocity]))
(defn quadrant [robot gridsize]
  (println 'debug robot gridsize)
  (let [
        loc (first robot)
        left (< (first loc) (first gridsize))
        right (> (first loc) (first gridsize))
        top (< (second loc) (second gridsize))
        bottom (> (second loc) (second gridsize))
        ]
    (cond (and top left) 1
          (and top right) 2
          (and bottom left) 3
          (and bottom right) 4
          true 0)))
(defn safety-factor [robots gridsize]
  (let [
        halfgrid (for [x gridsize] (/ (- x 1) 2))
        grouped (group-by (fn [robot] (quadrant robot halfgrid)) robots)]
    (*
       (count (get grouped 1))
       (count (get grouped 2))
       (count (get grouped 3))
       (count (get grouped 4))
       )))
(defn -main []
  (let [
        gridsize [101 103]
        parsed (for [line (line-seq (java.io.BufferedReader. *in*))] (parse-input line))
        iterated (first (drop 100 (iterate (fn [x] (for [robot x] (step robot gridsize))) parsed)))
        answer (safety-factor iterated gridsize)
        ]
    (println answer)
    ))
