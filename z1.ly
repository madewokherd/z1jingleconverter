\version "2.20.0"

#(define (convert-music state music) state)

recorderTune = #(define-void-function (name music) (string? ly:music?)
    (define state (list
        (cons 'output (open-output-file (string-append name ".bin")))))
    (displayMusic (open-output-file "debug.txt") music)
    (display "test" (assoc-ref state 'output))
    (define end-state (convert-music state music))
    (close-port (assoc 'output end-state)))

\recorderTune "test tune" { \relative { c d e } }
