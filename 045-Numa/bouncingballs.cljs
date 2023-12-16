(ns bouncing-ball.core
  (:require [quil.core :as q]))

(def balls (atom []))
(def antal (atom 0))

(defn Ball [x y radius dx dy colors]
	(let [antal (atom 0)]
		{:x x
		:y y
		:radius radius
		:dx dx
		:dy dy
		:colors colors
		:draw (fn []
			(q/stroke-weight 2)
			(swap! antal inc)
			(q/fill (nth colors (mod @antal (count colors))))
			(q/circle @x @y @radius))
		:update-position (fn []
			(swap! x + @dx)
			(swap! y + @dy))
		:update-speed (fn []
			(if (or (< @x @radius) (> @x (q/width)) )
				(swap! dx -))
			(if (> @y (q/height))
				(swap! dy -)
				(swap! dy inc)))})))

(defn setup []
	(q/defsketch bouncing-ball
		:size [(- (q/window-width) 50) (- (q/window-height) 50)]
		:setup (fn []
			(q/stroke "black")
			(q/background 192))))

(defn draw []
	(q/text-size 50)
	(q/fill 0)
	(q/text (str @antal) 100 100)
	(doseq [ball @balls]
		(-> ball
			(:draw)
			(:update-position)
			(:update-speed))))

(defn -main []
	(setup)
	(q/defsketch bouncing-ball
		:draw draw
		:setup setup
		:size [(- (q/window-width) 50) (- (q/window-height) 50)]))

(-main)
