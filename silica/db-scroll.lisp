;; -*- mode: common-lisp; package: silica -*-
;;
;;				-[]-
;; 
;; copyright (c) 1985, 1986 Franz Inc, Alameda, CA  All rights reserved.
;; copyright (c) 1986-1991 Franz Inc, Berkeley, CA  All rights reserved.
;;
;; The software, data and information contained herein are proprietary
;; to, and comprise valuable trade secrets of, Franz, Inc.  They are
;; given in confidence by Franz, Inc. pursuant to a written license
;; agreement, and may be stored and used only in accordance with the terms
;; of such license.
;;
;; Restricted Rights Legend
;; ------------------------
;; Use, duplication, and disclosure of the software, data and information
;; contained herein by any agency, department or entity of the U.S.
;; Government are subject to restrictions of Restricted Rights for
;; Commercial Software developed at private expense as specified in FAR
;; 52.227-19 or DOD FAR Suppplement 252.227-7013 (c) (1) (ii), as
;; applicable.
;;
;; $fiHeader: db-scroll.cl,v 1.2 92/01/06 20:44:17 cer Exp $

(in-package :silica)


(defclass scroller-pane (client-space-requirement-mixin
			 layout-pane)
	  (vertical-scrollbar
	   horizontal-scrollbar
	   contents
	   viewport))

(defmethod initialize-instance :after ((pane scroller-pane) 
				       &key contents frame-manager frame)
  (with-slots 
      (vertical-scrollbar horizontal-scrollbar (c contents)
			  viewport)
      pane
    (with-look-and-feel-realization (frame-manager frame)
      (setf vertical-scrollbar (realize-pane 
				'scroll-bar 
				:orientation :vertical
				:client pane
				:id :vertical)
	    horizontal-scrollbar (realize-pane 'scroll-bar 
					       :id :horizontal
					       :client pane
					       :orientation :horizontal)
	    c contents
	    viewport (realize-pane 'viewport))
      (sheet-adopt-child pane
			 (tabling ()
				  (viewport vertical-scrollbar)
				  (horizontal-scrollbar nil))))
    (sheet-adopt-child viewport c)
    ;; Add callbacks
    ))

(defmethod clim-internals::pane-scroller-sheet (x)
  (and (clim-internals::pane-viewport-sheet x)
       (sheet-parent (sheet-parent x))
       (typep (sheet-parent (sheet-parent (sheet-parent x)))
	      'scroller-pane)
       (sheet-parent (sheet-parent (sheet-parent x)))))

(defmethod allocate-space ((pane scroller-pane) width height)
  ;; decide how much space the scrollbars want and give the rest of
  ;; the space to the viewport
  (allocate-space (sheet-child pane) width height)
  )  

(defmethod compose-space ((pane scroller-pane))
  (compose-space (sheet-child pane)))

(defun update-scrollbars (vp)
  (with-bounding-rectangle* (minx miny maxx maxy)
    (stream-output-history
     (sheet-child vp))
    (with-bounding-rectangle* (vminx vminy vmaxx vmaxy)
      (xm-viewport-viewport vp)
      (with-slots (horizontal-scrollbar vertical-scrollbar)
	  (sheet-parent (sheet-parent vp))
	(update-scrollbar 
	 vertical-scrollbar
	 miny
	 maxy
	 vminy
	 vmaxy)
	(update-scrollbar 
	 horizontal-scrollbar
	 minx
	 maxx
	 vminx
	 vmaxx)))))

(defun  update-scrollbar (scrollbar minx maxx vminx vmaxx)
  (declare (optimize (safety 0) (speed 3)))
  (let*  ((size (truncate (* 100 
			     (the single-float
			       (if (zerop (- maxx minx))
				 1.0
			       (min 1.0  (the single-float
					   (/ (float (- vmaxx vminx))
					    (float (- maxx minx))))))))))
	  (pos (min 1.0
		    (max 0.0
			 (if (zerop (- (- maxx minx) (- vmaxx vminx)))
			     0.0
			   (the single-float 
			     (/ (float (- vminx minx))
			      (float (- (- maxx minx) (- vmaxx vminx)))))))))
	  (value (min (- 100 size) 
		      (truncate (* 100 pos)))))
    ;;--- is this safe
    (declare (type fixnum size value)
	     (type single-float pos))
	     
    (with-slots (current-size current-value) scrollbar
      (unless (and current-size
		   current-value
		   (eq current-size size)
		   (eq current-value value))
	(setf current-size size
	      current-value value)
	(change-scrollbar-values scrollbar 
				 :slider-size size
				 :value value)))))



(defmethod scrollbar-value-changed-callback :before
	   ((sheet scrollbar)
	    (client scroller-pane) 
	    id value
	    size)
  (declare (ignore id))
  (with-slots (current-size current-value) sheet
    (setf current-size (truncate size)
	  current-value (truncate value))))
  

(defmethod scrollbar-value-changed-callback (sheet 
					     (client scroller-pane) 
					     id value
					     size)
  (declare (ignore sheet))
  (with-slots (viewport contents) client
    (let* ((extent (stream-output-history
		   contents))
	  (vp viewport)
	  (viewport (silica::xm-viewport-viewport vp)))
      (case id
	(:vertical
	 (clim-internals::scroll-extent
	  contents
	  :x (bounding-rectangle-min-x viewport)
	  :y (truncate
	      (+ (bounding-rectangle-min-y extent)
		 (* (max 0 (- (bounding-rectangle-height extent)
			      (bounding-rectangle-height viewport)))
		    (if (= size 100)
			0
		      (/ value (- 100 size))))))))
	(:horizontal
	 (clim-internals::scroll-extent
	  contents
	  :x (truncate
	      (* (max 0 (- (bounding-rectangle-width extent)
			   (bounding-rectangle-width viewport)))
		 (if (= size 100)
		     0
		   (/ value (- 100 size)))))
	  :y (bounding-rectangle-min-y viewport)))))))
  