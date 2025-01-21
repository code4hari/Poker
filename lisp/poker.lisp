;; poker-hand-analyzer.lisp
;; A complete implementation of the Five-Card Stud Poker Hand Analyzer

(defpackage :poker-hand-analyzer
  (:use :cl)
  (:export :main))

(in-package :poker-hand-analyzer)

;; Card class definition
(defclass card ()
  ((face :initarg :face :accessor card-face)
   (suit :initarg :suit :accessor card-suit)))

(defmethod print-object ((card card) stream)
  (format stream "~A~A" (card-face card) (card-suit card)))

(defun make-card (face suit)
  (make-instance 'card :face face :suit suit))

;; Deck management
(defun create-deck ()
  (let ((faces '(2 3 4 5 6 7 8 9 10 J Q K A))
        (suits '(D C H S))
        deck)
    (dolist (suit suits)
      (dolist (face faces)
        (push (make-card face suit) deck)))
    (nreverse deck)))

(defun shuffle-deck (deck)
  (loop for i from (length deck) downto 2
        do (rotatef (nth (random i) deck)
                    (nth (1- i) deck)))
  deck)

;; Hand ranking and comparison
(defun card-value (card)
  (case (card-face card)
    (A 14)
    (K 13)
    (Q 12)
    (J 11)
    (otherwise (card-face card))))

(defun suit-rank (suit)
  (case suit
    (D 1)
    (C 2)
    (H 3)
    (S 4)))

;; Hand type detection functions
(defun is-flush-p (hand)
  (= 1 (length (remove-duplicates (mapcar #'card-suit hand)))))

(defun is-straight-p (hand)
  (let* ((sorted-values (sort (mapcar #'card-value hand) #'<))
         (min-value (first sorted-values))
         (max-value (car (last sorted-values))))
    (or (and (= (length (remove-duplicates sorted-values)) 5)
             (= (- max-value min-value) 4))
        ;; Special case for A-2-3-4-5 straight
        (and (equal sorted-values '(2 3 4 5 14))))))

(defun hand-type (hand)
  (let* ((face-counts (make-hash-table))
         (sorted-values (sort (mapcar #'card-value hand) #'>))
         (unique-values (remove-duplicates sorted-values)))
    
    (dolist (card hand)
      (let ((value (card-value card)))
        (setf (gethash value face-counts)
              (1+ (gethash value face-counts 0)))))
    
    (cond
      ;; Royal Straight Flush
      ((and (is-flush-p hand)
            (is-straight-p hand)
            (member 14 sorted-values)
            (member 10 sorted-values))
       10)
      
      ;; Straight Flush
      ((and (is-flush-p hand) (is-straight-p hand)) 9)
      
      ;; Four of a Kind
      ((member 4 (loop for v being the hash-values of face-counts collect v)) 8)
      
      ;; Full House
      ((and (member 3 (loop for v being the hash-values of face-counts collect v))
            (member 2 (loop for v being the hash-values of face-counts collect v)))
       7)
      
      ;; Flush
      ((is-flush-p hand) 6)
      
      ;; Straight
      ((is-straight-p hand) 5)
      
      ;; Three of a Kind
      ((member 3 (loop for v being the hash-values of face-counts collect v)) 4)
      
      ;; Two Pair
      ((= 2 (count 2 (loop for v being the hash-values of face-counts collect v))) 3)
      
      ;; Pair
      ((member 2 (loop for v being the hash-values of face-counts collect v)) 2)
      
      ;; High Card
      (t 1))))

;; Tie-breaking functions
(defun compare-hands (hand1 hand2)
  (let ((type1 (hand-type hand1))
        (type2 (hand-type hand2)))
    (cond
      ((> type1 type2) t)
      ((< type1 type2) nil)
      (t (break-tie hand1 hand2)))))

(defun break-tie (hand1 hand2)
  (let ((type (hand-type hand1)))
    (case type
      ;; Royal Straight Flush and Straight Flush
      ((9 10) 
       (let ((max-suit1 (apply #'max (mapcar #'suit-rank (mapcar #'card-suit hand1))))
             (max-suit2 (apply #'max (mapcar #'suit-rank (mapcar #'card-suit hand2)))))
         (> max-suit1 max-suit2)))
      
      ;; Flush and Straights
      ((5 6) 
       (let* ((sorted1 (sort (mapcar #'card-value hand1) #'>))
              (sorted2 (sort (mapcar #'card-value hand2) #'>))
              (high-card1 (position-if (lambda (x) (= x (first sorted1))) sorted1))
              (high-card2 (position-if (lambda (x) (= x (first sorted2))) sorted2)))
         (if (= (first sorted1) (first sorted2))
             (> (suit-rank (card-suit (nth high-card1 hand1)))
                (suit-rank (card-suit (nth high-card2 hand2))))
             (> (first sorted1) (first sorted2)))))
      
      ;; Two Pair and One Pair
      ((2 3)
       (let ((pair-values1 (loop for card in hand1
                                 for value = (card-value card)
                                 when (= 2 (count value (mapcar #'card-value hand1)))
                                 collect value))
             (pair-values2 (loop for card in hand2
                                 for value = (card-value card)
                                 when (= 2 (count value (mapcar #'card-value hand2)))
                                 collect value)))
         (cond
           ((> (apply #'max pair-values1) (apply #'max pair-values2)) t)
           ((< (apply #'max pair-values1) (apply #'max pair-values2)) nil)
           (t (let ((kicker1 (find-if (lambda (x) (not (member x pair-values1))) 
                                      (mapcar #'card-value hand1)))
                    (kicker2 (find-if (lambda (x) (not (member x pair-values2))) 
                                      (mapcar #'card-value hand2))))
                (if (= kicker1 kicker2)
                    (> (apply #'max (mapcar #'suit-rank 
                                            (remove-if-not 
                                             (lambda (card) (= (card-value card) kicker1)) 
                                             hand1)))
                       (apply #'max (mapcar #'suit-rank 
                                            (remove-if-not 
                                             (lambda (card) (= (card-value card) kicker2)) 
                                             hand2))))
                    (> kicker1 kicker2)))))))
      
      ;; High Card
      (1 (let ((sorted1 (sort (mapcar #'card-value hand1) #'>))
               (sorted2 (sort (mapcar #'card-value hand2) #'>)))
           (loop for v1 in sorted1
                 for v2 in sorted2
                 do (cond 
                      ((> v1 v2) (return t))
                      ((< v1 v2) (return nil)))
             finally 
             (let ((high-card1 (find-if (lambda (x) (= x (first sorted1))) hand1))
                   (high-card2 (find-if (lambda (x) (= x (first sorted2))) hand2)))
               (> (suit-rank (card-suit high-card1))
                  (suit-rank (card-suit high-card2))))))
      
      (otherwise nil))))

;; Input parsing functions
(defun parse-card (card-string)
  (let* ((card-string (string-trim " " card-string))
         (face (subseq card-string 0 (1- (length card-string))))
         (suit (subseq card-string (1- (length card-string))))
         (parsed-face (cond 
                        ((string= face "10") 10)
                        ((string= face "J") 'J)
                        ((string= face "Q") 'Q)
                        ((string= face "K") 'K)
                        ((string= face "A") 'A)
                        (t (parse-integer face)))))
    (make-card parsed-face suit)))

(defun read-hands-from-file (filename)
  (with-open-file (input filename)
    (loop for line = (read-line input nil nil)
          while line
          collect (mapcar #'parse-card 
                          (mapcar #'string-trim 
                                  (split-sequence:split-sequence #\, line))))))

(defun check-duplicates (hands)
  (let ((all-cards (apply #'append hands)))
    (loop for (card . rest) on all-cards
          do (when (member card rest :test #'equal)
               (format t "*** ERROR - DUPLICATED CARD FOUND IN DECK ***~%")
               (format t "*** DUPLICATE: ~A~%" card)
               (return-from check-duplicates nil)))
    t))

;; Main program logic
(defun analyze-hands (hands)
  (unless (check-duplicates hands)
    (return-from analyze-hands nil))
  
  (let* ((sorted-hands (sort hands #'compare-hands))
         (hand-types '("High Card" "One Pair" "Two Pair" 
                       "Three of a Kind" "Straight" "Flush" 
                       "Full House" "Four of a Kind" 
                       "Straight Flush" "Royal Straight Flush")))
    
    (format t "--- WINNING HAND ORDER ---~%")
    (loop for hand in (reverse sorted-hands)
          for hand-type in (nthcdr (- (length hand-types) (length sorted-hands)) hand-types)
          do (format t "~{~A~^ ~} - ~A~%" 
                     (mapcar #'print-object-to-string hand) 
                     hand-type))))

(defun print-object-to-string (obj)
  (with-output-to-string (stream)
    (print-object obj stream)))

(defun main (&optional filename)
  (format t "*** P O K E R H A N D A N A L Y Z E R ***~%")
  
  (let (hands)
    (if filename
        (progn
          (format t "*** USING TEST DECK ***~%")
          (format t "*** File: ~A~%" filename)
          (with-open-file (input filename)
            (let ((file-contents (read-line input)))
              (format t "~A~%" file-contents))
            (file-position input 0))
          (setf hands (read-hands-from-file filename))
          
          (format t "*** Here are the six hands...~%")
          (dolist (hand hands)
            (format t "~{~A ~}~%" (mapcar #'print-object-to-string hand))))
        
        (progn
          (format t "*** USING RANDOMIZED DECK OF CARDS ***~%")
          (let* ((deck (shuffle-deck (create-deck)))
                 (six-hands (loop for i from 1 to 6
                                  collect (loop repeat 5
                                               collect (pop deck)))))
            (format t "*** Shuffled 52 card deck:~%")
            (loop for i from 0 below 52 by 12
                  do (format t "~{~A ~}~%" 
                             (mapcar #'print-object-to-string 
                                     (subseq deck i (min (+ i 12) 52)))))
            
            (format t "*** Here are the six hands...~%")
            (dolist (hand six-hands)
              (format t "~{~A ~}~%" (mapcar #'print-object-to-string hand)))
            
            (format t "*** Here is what remains in the deck...~%")
            (format t "~{~A ~}~%" (mapcar #'print-object-to-string deck))
            
            (setf hands six-hands))))
    
    (analyze-hands hands)))

;; Package for splitting strings
(defpackage :split-sequence
  (:use :cl)
  (:export :split-sequence))

(in-package :split-sequence)

(defun split-sequence (delimiter sequence &key (test #'eql))
  (let ((result '())
        (start 0))
    (loop for end = (position delimiter sequence :start start :test test)
          do (if end
                 (progn 
                   (push (subseq sequence start end) result)
                   (setf start (1+ end)))
                 (progn
                   (push (subseq sequence start) result)
                   (return))))
    (nreverse result)))