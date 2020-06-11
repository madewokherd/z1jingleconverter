\version "2.20.0"

recorderTune = #(letrec

( ; definition pairs

; convert-music takes a state and music value, and returns a new state
; data is written to (assoc-ref state 'output)
(convert-music (lambda (state music)
    (case (ly:music-property music 'name)
        ((SequentialMusic)
            (convert-music-sequence state (ly:music-property music 'elements)))
        (else
            (display (ly:music-property music 'name) (open-output-file "unk.txt"))
            state))))

(convert-music-sequence (lambda (state musics)
    (if (null? musics)
        state
        (convert-music-sequence (convert-music state (car musics)) (cdr musics)))))

) ; end definitions

(define-void-function (name music) (string? ly:music?)
    (define state (list
        (cons 'output (open-output-file (string-append name ".bin")))))
    (displayMusic (open-output-file "debug.txt") music)
    (display "test" (assoc-ref state 'output))
    (convert-music state music)
    (close-port (assoc 'output state)))

)

\recorderTune "test tune" { \relative { c d e } }
