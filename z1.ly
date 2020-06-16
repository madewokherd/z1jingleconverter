\version "2.20.0"

#(define-public debug-port (open-output-file "debug.txt"))

#(define-public (debug-write obj)
    (display obj debug-port)
    (display "\n" debug-port))

#(define-public pitches #(
    -1 -1 -1 -1 #x62 #x64 #x66 -1 #x68 #x6a #x6c #x6e ; octave -2
    #x70 #x72 #x0a #x0c #x0e #x10 #x12 #x14 #x16 #x18 #x1a #x1c ; octave -1
    #x1e #x20 #x22 #x24 #x26 #x28 #x2a #x2c #x2e #x30 #x32 #x34 ; octave 0
    #x36 #x38 #x3a #x3c #x3e #x40 #x06 #x42 #x44 #x46 #x48 #x4a ; octave 1
    -1 #x4e #x50 #x52 #x54 #x56 #x58 #x5a -1 -1 -1 #x5c ; octave 2
    #x5e ; octave 2
    ))

#(define-public durations '(
    (3/4 . #xa0)
    (1/2 . #xb0)
    (1/4 . #x9c)
    (3/16 . #x98)
    (1/8 . #x94)
    (3/32 . #x90)
    (1/16 . #x8c)))

#(define-public (lookup-duration-rec duration lst)
    (if (null? lst)
        (begin
            (debug-write "Duration cannot be expressed:")
            (debug-write duration))
        (if (>= duration (car (car lst)))
            (cons (car lst) (- (car (car lst)) duration))
            (lookup-duration-rec duration (cdr lst)))))

#(define-public (lookup-duration duration)
    (lookup-duration-rec duration durations))

#(define-public (write-byte state value)
    (display (integer->char value) (assoc-ref state 'output)))

#(define-public (assoc-with asc key value)
    (let ((result (list-copy asc)))
        (assoc-set! result key value)
        result))

#(define-public (emit-note state z1pitch duration)
    (let* ((ret (lookup-duration duration))
           (out-duration (car (car ret)))
           (z1duration (cdr (car ret)))
           (rest (cdr ret)))
          (debug-write (assoc-ref state 'last-duration))
          (debug-write z1duration)
          (if (eq? (assoc-ref state 'last-duration) z1duration)
              #f
              (write-byte state z1duration))
          (write-byte state z1pitch)
          (if (eq? rest 0)
              (assoc-with state 'last-duration z1duration)
              (emit-note (assoc-with state 'last-duration -1) 8 rest))))

% convert-music takes a state and music value, and returns a new state
% data is written to (assoc-ref state 'output)
#(define-public (convert-music state music)
    (case (ly:music-property music 'name)
        ((SequentialMusic)
            (convert-music-sequence state (ly:music-property music 'elements)))
        ((RelativeOctaveMusic)
            (convert-music state (ly:music-property music 'element)))
        ((NoteEvent)
            (let* ((pitch (ly:music-property music 'pitch))
                   (index (+ (ly:pitch-semitones pitch) 36))
                   (pitch-value (array-ref pitches index))
                   (ly-duration (ly:music-property music 'duration))
                   (duration (ly:moment-main (ly:duration-length ly-duration))))
            (emit-note state pitch-value duration)))
        (else
            (display (ly:music-property music 'name) (open-output-file "unk.txt"))
            state)))

#(define-public (convert-music-sequence state musics)
    (if (null? musics)
        state
        (convert-music-sequence (convert-music state (car musics)) (cdr musics))))

recorderTune = #(define-void-function (name music) (string? ly:music?)
    (define state (list
        (cons 'output (open-output-file (string-append name ".bin")))
        (cons 'last-duration -1)))
    (displayMusic debug-port music)
    (convert-music state music)
    (write-byte state 0)
    (close-port (assoc-ref state 'output)))

\recorderTune "Prelude of Light" { \absolute { d'8 a2 d'8 a b d'2 } }
