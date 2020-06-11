\version "2.20.0"

#(define (scheme-function args) #t)

recorderTune = #(define-void-function (name music) (string? ly:music?)
    (define f (open-output-file "display.txt"))
    (display name f)
    (displayMusic f music))

\recorderTune "test tune" { \relative { c d e } }
