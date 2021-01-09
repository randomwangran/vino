;;; vino.el --- Wine tracking in Emacs -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2021 Boris Buliga
;;
;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;; Package-Version: 1.0
;; Package-Requires: ((emacs "27.1"))
;;
;; Created: 09 Jan 2021
;;
;; URL: https://github.com/d12frosted/vino.el
;;
;; License: GPLv3
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; It's your cellar, your dear cantina.
;;
;;; Code:

(require 'vulpea)
(require '+fun)

;;; Grapes
;;

(defvar vino-grape-template
  '("d" "default" plain
    #'org-roam-capture--get-point
    "%(vino-resources-template)%?"
    :file-name "wine/grape/%<%Y%m%d%H%M%S>-${slug}"
    :head "#+TITLE: ${title}\n#+TIME-STAMP: <>\n\n"
    :unnarrowed t
    :immediate-finish t)
  "Capture template for grape entry.")

(defun vino-grape-select ()
  "Select a grape note.

See `vulpea' documentation for more information on note
structure."
  (let ((result
         (vulpea-select
          "Grape"
          nil nil
          (lambda (note)
            (let ((tags (plist-get (cdr note) :tags)))
              (and (seq-contains-p tags "wine")
                   (seq-contains-p tags "grape")))))))
    (if (plist-get result :id)
        result
      (let ((org-roam-capture-immediate-template vino-grape-template)
            (title (plist-get result :title)))
        (org-roam-find-file-immediate title nil nil t)
        (org-roam-db-build-cache)
        (seq-find
         (lambda (note)
           (seq-contains-p (plist-get note :tags) "grape"))
         (vulpea-db-search-by-title title))))))

;;; Producers

(defun vino-producer-select ()
  "Select a producer note.

See `vulpea' documentation for more information on note
structure."
  (vulpea-select
   "Producer"
   nil nil
   (lambda (note)
     (let ((tags (plist-get (cdr note) :tags)))
       (and (seq-contains-p tags "wine")
            (seq-contains-p tags "producer"))))))

;;; Utilities

(defun vino-resources-template ()
  "Query for resource URL and return it as a meta string."
  (seq-reduce
   (lambda (r a)
     (concat r "- resources :: " a "\n"))
   (+repeat-fn
    (lambda ()
      (let ((url (read-string "URL: ")))
        (when (not (string-empty-p url))
          (org-link-make-string
           url
           (or (ignore-errors (url-domain (url-generic-parse-url url)))
               (read-string "Description: "))))))
    (lambda (a) (not (null a))))
   ""))

(provide 'vino)
;;; vino.el ends here
