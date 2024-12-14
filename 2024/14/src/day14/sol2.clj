(ns day14.sol2
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
    [(for [x (map vector coord velocity gridsize)] (add-wrap x)) velocity])
  )
(defn quadrant [robot gridsize]
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
;        iterated (first (drop 100 (iterate step-robots(fn [x] (for [robot x] (step robot gridsize))) parsed)))
(defn output-grid [gridsize robots]
  (let [
        empty-grid (vec (take (second gridsize) (iterate (fn [x] 
                                                           (vec (take (first gridsize)
                                                                      (iterate (fn [x] 0) 0))
                                                                )) 0)))
        grouped (group-by (fn [robot] (first robot)) robots)
        filled-grid (vec (for [x (take (second gridsize) (iterate inc 0))]
                           (vec (for [y (take (first gridsize) (iterate inc 0))]
                                  (let [cnt (count (get grouped [x y]))]
                                    (if (< 0 cnt) "X" " ")
                                        )))))
        ]
    ; (println 'full-grid filled-grid)
    (println (count filled-grid))
    (doseq [line filled-grid] (println 'empty-grid (eval (cons str line))))
    (println 'end)
    ))
(defn step-robots [n gridsize robots]
  (let [
        new-positions (for [robot robots] (step robot gridsize))
        ]

    (println 'n n)
    (output-grid gridsize robots)
    new-positions
    ))
(defn -main []
  (let [
        gridsize [101 103]
        parsed (for [line (line-seq (java.io.BufferedReader. *in*))] (parse-input line))
        iterated (first (drop (* 101 103) (iterate (fn [[n robots]] [(inc n) (step-robots n gridsize robots)]) [0 parsed])))
        answer (safety-factor iterated gridsize)
        ]
    (println answer)
    ))
