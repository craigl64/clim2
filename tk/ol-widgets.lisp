;; -*- mode: common-lisp; package: xt -*-
;;
;;				-[]-
;; 
;; copyright (c) 1985, 1986 Franz Inc, Alameda, CA  All rights reserved.
;; copyright (c) 1986-1992 Franz Inc, Berkeley, CA  All rights reserved.
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
;; 52.227-19 or DOD FAR Supplement 252.227-7013 (c) (1) (ii), as
;; applicable.
;;
;; $fiHeader$

(in-package :xt)


(defmethod make-widget ((w menu-shell) &rest args &key parent (name "") &allow-other-keys)
  (remf :parent args)
  (remf :name args)
  (apply #'create-popup-shell name (class-of w) parent args))


(defmethod make-widget ((w transient-shell) &rest args &key parent (name "") &allow-other-keys)
  (remf :parent args)
  (remf :name args)
  (apply #'create-popup-shell name (class-of w) parent args))


(tk::add-resource-to-class (find-class 'menu-shell)
			   (make-instance 'resource
					  :name :menu-pane
					  :type 'tk::widget
					  :original-name 
					  (string-to-char*
					   "menuPane")))
