;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Package: CL-USER; Base: 10; Lowercase: Yes -*-

;; $fiHeader: sysdcl.lisp,v 1.4 92/09/24 09:40:40 cer Exp $

(in-package #-ANSI-90 :user #+ANSI-90 :cl-user)

"Copyright (c) 1990, 1991, 1992 Symbolics, Inc.  All rights reserved."

(clim-defsys:defsystem postscript-clim
    (:default-pathname #+Genera "SYS:CLIM;REL-2;POSTSCRIPT;"
		       #-Genera (frob-pathname "postscript")
     :default-binary-pathname #+Genera "SYS:CLIM;REL-2;POSTSCRIPT;"
			      #-Genera (frob-pathname "postscript")
     :load-before-compile (clim-standalone))
  ("pkgdcl")
  ("postscript-port")
  ("postscript-medium")
  ("laserwriter-metrics"))

#+Genera
(clim-defsys:import-into-sct 'postscript-clim
  :pretty-name "PostScript CLIM"
  :default-pathname "SYS:CLIM;REL-2;POSTSCRIPT;"
  :required-systems '(clim)
  :bug-reports "Bug-CLIM"
  :patches-reviewed "Bug-CLIM-Doc")