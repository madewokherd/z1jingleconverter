\version "2.20.0"

#(define-public debug-port (open-output-file "debug.txt"))


#(define-public pitches #(
    -1 -1 -1 -1 #x62 #x64 #x66 -1 #x68 #x6a #x6c #x6e ; octave -2
    #x70 #x72 #x0a #x0c #x0e #x10 #x12 #x14 #x16 #x18 #x1a #x1c ; octave -1
    #x1e #x20 #x22 #x24 #x26 #x28 #x2a #x2c #x2e #x30 #x32 #x34 ; octave 0
    #x36 #x38 #x3a #x3c #x3e #x40 #x06 #x42 #x44 #x46 #x48 #x4a ; octave 1
    -1 #x4e #x50 #x52 #x54 #x56 #x58 #x5a -1 -1 -1 #x5c ; octave 2
    #x5e ; octave 2
    ))

#(define-public (write-byte state value)
    (display (integer->char value) (assoc-ref state 'output)))

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
                   (pitch-value (array-ref pitches index)))
            (write-byte state pitch-value)
            state))
        (else
            (display (ly:music-property music 'name) (open-output-file "unk.txt"))
            state)))

#(define-public (convert-music-sequence state musics)
    (if (null? musics)
        state
        (convert-music-sequence (convert-music state (car musics)) (cdr musics))))

recorderTune = #(define-void-function (name music) (string? ly:music?)
    (define state (list
        (cons 'output (open-output-file (string-append name ".bin")))))
    (displayMusic debug-port music)
    (write-byte state 176)
    (convert-music state music)
    (write-byte state 0)
    (close-port (assoc-ref state 'output)))

\recorderTune "Prelude of Light" { \absolute { d'8 a2 d'8 a b d'2 } }
