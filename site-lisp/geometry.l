;;;;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; geometry.l
;;;     xyzzy自体のサイズ・位置変更&保存
;;;
;;; * 使用法
;;;   ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下を記述します。
;;;     (require "geometry")
;;;
;;; * 依存
;;;  api.lに依存しています。
;;;  2008-02-09時点での最新版は http://xyzzy.s53.xrea.com/ni/api2006.06.15.tgz です。
;;;
;;; * 履歴
;;;   2008-02-09 : $XYZZY/site-lisp/siteinit.l でロードするとメニューが
;;;                消える問題に対処
;;;   2006-07-30 辺り : 作ったらしい
;;; 
;;; * ライセンス
;;; Copyright (c) 2008 NANRI <southly@gmail.com>
;;; 
;;; Permission is hereby granted, free of charge, to any person obtaining a 
;;; copy of this software and associated documentation files (the "Software"), 
;;; to deal in the Software without restriction, including without 
;;; limitation the rights to use, copy, modify, merge, publish, distribute, 
;;; sublicense, and/or sell copies of the Software, and to permit persons to 
;;; whom the Software is furnished to do so, subject to the following 
;;; conditions:
;;; 
;;; The above copyright notice and this permission notice shall be included 
;;; in all copies or substantial portions of the Software.
;;; 
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
;;; OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
;;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
;;; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
;;; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
;;; TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
;;; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;;;
(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "wip/winapi")
  (require "api"))

(provide "geometry")

(in-package "editor")
(export '(maximize-height-window maximize-width-window
	  move-to-left-window move-to-top-window move-to-right-window move-to-bottom-window
	  move-window
	  *geometry-presets-size* *geometry-presets*))

(defvar *geometry-presets-size* *menu-history-max*)
(defvar *geometry-popup-menu* nil)
(define-history-variable *geometry-presets* nil)

; 上下に最大化
(defun maximize-height-window ()
  (interactive)
  (let ((wr (winapi:make-RECT)))
    (winapi:GetWindowRect (get-window-handle) wr)
    (winapi:MoveWindow (get-window-handle)
		       (winapi:RECT-left wr)
		       0
		       (- (winapi:RECT-right wr) (winapi:RECT-left wr))
		       (- (winapi:GetSystemMetrics winapi:SM_CYMAXIMIZED) (* 2 (winapi:GetSystemMetrics winapi:SM_CYSIZEFRAME)))
		       1))
  t)

; 左右に最大化
(defun maximize-width-window ()
  (interactive)
  (let ((wr (winapi:make-RECT)))
    (winapi:GetWindowRect (get-window-handle) wr)
    (winapi:MoveWindow (get-window-handle)
		       0
		       (winapi:RECT-top wr)
		       (- (winapi:GetSystemMetrics winapi:SM_CXMAXIMIZED) (* 2 (winapi:GetSystemMetrics winapi:SM_CXSIZEFRAME)))
		       (- (winapi:RECT-bottom wr) (winapi:RECT-top wr))
		       1))
  t)

; 左に寄せる
(defun move-to-left-window ()
  (interactive)
  (let ((wr (winapi:make-RECT)))
    (winapi:GetWindowRect (get-window-handle) wr)
    (winapi:MoveWindow (get-window-handle)
		       0
		       (winapi:RECT-top wr)
		       (- (winapi:RECT-right wr) (winapi:RECT-left wr))
		       (- (winapi:RECT-bottom wr) (winapi:RECT-top wr))
		       1))
  t)

; 上に寄せる
(defun move-to-top-window ()
  (interactive)
  (let ((wr (winapi:make-RECT)))
    (winapi:GetWindowRect (get-window-handle) wr)
    (winapi:MoveWindow (get-window-handle)
		       (winapi:RECT-left wr)
		       0
		       (- (winapi:RECT-right wr) (winapi:RECT-left wr))
		       (- (winapi:RECT-bottom wr) (winapi:RECT-top wr))
		       1))
  t)

; 右に寄せる
(defun move-to-right-window ()
  (interactive)
  (let ((wr (winapi:make-RECT)))
    (winapi:GetWindowRect (get-window-handle) wr)
    (winapi:MoveWindow (get-window-handle)
		       (- (winapi:GetSystemMetrics winapi:SM_CXMAXIMIZED) (- (winapi:RECT-right wr) (winapi:RECT-left wr)) (* 2 (winapi:GetSystemMetrics winapi:SM_CXSIZEFRAME)))
		       (winapi:RECT-top wr)
		       (- (winapi:RECT-right wr) (winapi:RECT-left wr))
		       (- (winapi:RECT-bottom wr) (winapi:RECT-top wr))
		       1))
  t)

; 下に寄せる
(defun move-to-bottom-window ()
  (interactive)
  (let ((wr (winapi:make-RECT)))
    (winapi:GetWindowRect (get-window-handle) wr)
    (winapi:MoveWindow (get-window-handle)
		       (winapi:RECT-left wr)
		       (- (winapi:GetSystemMetrics winapi:SM_CYMAXIMIZED) (- (winapi:RECT-bottom wr) (winapi:RECT-top wr)) (* 2 (winapi:GetSystemMetrics winapi:SM_CYSIZEFRAME)))
		       (- (winapi:RECT-right wr) (winapi:RECT-left wr))
		       (- (winapi:RECT-bottom wr) (winapi:RECT-top wr))
		       1))
  t)

(defun move-window ()
  "左端・上端・幅・高さを指定して位置と大きさを変更"
  (interactive)
  (let ((wr (winapi:make-RECT)))
    (winapi:GetWindowRect (get-window-handle) wr)
    (let ((left (winapi:RECT-left wr))
	  (top (winapi:RECT-top wr))
	  (width (- (winapi:RECT-right wr) (winapi:RECT-left wr)))
	  (height (- (winapi:RECT-bottom wr) (winapi:RECT-top wr))))
      (winapi:MoveWindow (get-window-handle)
			 (parse-integer (read-string (format nil "left(~D): " left) :default (format nil "~D" left)))
			 (parse-integer (read-string (format nil "top(~D): " top) :default (format nil "~D" top)))
			 (parse-integer (read-string (format nil "width(~D): " width) :default (format nil "~D" width)))
			 (parse-integer (read-string (format nil "height(~D): " height) :default (format nil "~D" height)))
			 1)))
  t)

(defun set-geometry (text)
  (string-match "(\\([0-9]+\\),\\([0-9]+\\))-(\\([0-9]+\\),\\([0-9]+\\))" text)
  (let ((left (parse-integer (match-string 1)))
	(top (parse-integer (match-string 2)))
	(right (parse-integer (match-string 3)))
	(bottom (parse-integer (match-string 4))))
    (winapi:MoveWindow (get-window-handle) left top (- right left) (- bottom top) 1))
  t)

(defun recode-geometry ()
  (interactive)
  (let ((wr (winapi:make-RECT)))
    (winapi:GetWindowRect (get-window-handle) wr)
    (let ((text (format nil "(~D,~D)-(~D,~D)" (winapi:RECT-left wr) (winapi:RECT-top wr) (winapi:RECT-right wr) (winapi:RECT-bottom wr))))
      (setq *geometry-presets* (delete text *geometry-presets* :test #'string= :key #'car))
      (push (list text (winapi:RECT-left wr) (winapi:RECT-top wr) (- (winapi:RECT-right wr) (winapi:RECT-left wr)) (- (winapi:RECT-bottom wr) (winapi:RECT-top wr)))
	    *geometry-presets*)
      (when (< *geometry-presets-size* (length *geometry-presets*))
	(setq *geometry-presets* (nbutlast *geometry-presets*)))))
  (add-geometry-presets-to-menu))

(defun add-geometry-presets-menu (menu texts fn)
  (when (menup menu)
    (while (delete-menu menu 0 t))
    (do ((text texts (cdr text))
	 (count 1))
	((or (null text)
	     (> count *menu-history-max*))
	 t)
      (insert-menu-item menu (1- count) nil
			(format nil "&~:(~35r~): ~a"
				(rem count 36)
				(quote-string (car text) #\& #\&))
			(funcall fn (car text)))
      (incf count))))

(defun add-geometry-presets-to-menu ()
  (when (menup *app-menu*)
    (when *geometry-presets*
      (add-geometry-presets-menu *geometry-popup-menu*
				 (mapcar #'car *geometry-presets*)
				 #'(lambda (text)
				     #'(lambda ()
					 (interactive)
					 (let ((item (cdr (assoc text *geometry-presets* :test #'string=))))
					   (if item
					       (winapi:MoveWindow (get-window-handle) (first item) (second item) (third item) (fourth item) 1)
					     (set-geometry text))))))
      (add-menu-separator *geometry-popup-menu* :above-recode-geometry))
    (add-menu-item *geometry-popup-menu* nil "現在の位置とサイズを保存(&S)" 'recode-geometry)))

(defun insert-menu-for-move-window (&optional (tag :above-next-xyzzy))
  (when (menup *app-menu*)
    (let ((window-menu (get-menu *app-menu* 'window)))
      (insert-menu-separator window-menu (get-menu-position window-menu tag) :above-maximize-height-window)
      (insert-menu-item window-menu (get-menu-position window-menu tag) nil "上下に最大化(&H)" 'maximize-height-window)
      (insert-menu-item window-menu (get-menu-position window-menu tag) nil "左右に最大化(&W)" 'maximize-width-window)
      (insert-menu-item window-menu (get-menu-position window-menu tag) nil "左に寄せる(&<)" 'move-to-left-window)
      (insert-menu-item window-menu (get-menu-position window-menu tag) nil "右に寄せる(&>)" 'move-to-right-window)
      (insert-menu-item window-menu (get-menu-position window-menu tag) nil "上に寄せる(&^)" 'move-to-top-window)
      (insert-menu-item window-menu (get-menu-position window-menu tag) nil "下に寄せる(&_)" 'move-to-bottom-window)
      (insert-popup-menu window-menu (get-menu-position window-menu :above-next-xyzzy) *geometry-popup-menu* "既定"))))

(defun init-geometry-menu ()
  (unless *geometry-popup-menu*
    (setq *geometry-popup-menu* (create-popup-menu :geometry-popup)))
  (add-geometry-presets-to-menu)
  (insert-menu-for-move-window))

(add-hook '*init-app-menus-hook* 'init-geometry-menu)
