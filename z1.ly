\version "2.20.0"

#(define-public debug-port (open-output-file "debug.txt"))

#(define-public (debug-write obj)
    (display obj debug-port)
    (display "\n" debug-port))

#(define-public pitches #(
    #x74 -1 -1 -1 #x62 #x64 #x66 -1 #x68 #x6a #x6c #x6e ; octave -2
    #x70 #x4 #x0a #x0c #x0e #x10 #x12 #x14 #x16 #x18 #x1a #x1c ; octave -1
    #x1e #x20 #x22 #x24 #x26 #x28 #x2a #x2c #x2e #x30 #x32 #x34 ; octave 0
    #x36 #x38 #x3a #x3c #x3e #x40 #x06 #x42 #x44 #x48 #x46 #x4a ; octave 1
    #x2 #x4e #x50 #x52 -1 #x54 -1 #x56 #x58 #x5a -1 #x5c ; octave 2
    -1 #x5e ; octave 2
    ))

#(define-public (write-byte state value)
    (display (integer->char value) (assoc-ref state 'output)))

#(define-public (assoc-with asc key value)
    (let ((result (list-copy asc)))
        (assoc-set! result key value)
        result))

#(define-public (emit-note state z1pitch duration)
    (let* ((z1duration (+ #x80 (round (* (assoc-ref state 'tempo) duration)))))
          (if (> z1duration #xff)
              (debug-write "Note too long"))
          (if (eq? (assoc-ref state 'last-duration) z1duration)
              #f
              (write-byte state z1duration))
          (write-byte state z1pitch)
          (assoc-with state 'last-duration z1duration)))

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

recorderTune = #(define-void-function (name tempo music) (string? integer? ly:music?)
    (define state (list
        (cons 'output (open-output-file (string-append name ".bin")))
        (cons 'last-duration -1)
        (cons 'tempo tempo)))
    (debug-write name)
    (displayMusic debug-port music)
    (convert-music state music)
    (write-byte state 0)
    (close-port (assoc-ref state 'output)))

\recorderTune "Prelude of Light" 120 { \absolute { d'8 a2 d'8 a b d'2 } }

\recorderTune "Ballad of the Windfish" 160 { \relative { b'16 cis d2 b16 cis d2 cis16 b fis a4. b2 } }

\recorderTune "Vanilla" 160 { \relative { d'8 e d'4 cis16 c b2 } }

\recorderTune "Vanilla Death" 160 { \relative { dis'32 d cis c d cis c b cis c b ais c b ais a b ais a gis fis f e4 } }

\recorderTune "Kefka" 90 { \relative { e'4. b8 c a4 c8 d4 d c gis } }

\recorderTune "Super Mario Land Death" 45 { \relative { g'8 f e d c2 d e } }

\recorderTune "Go Go Power Rangers" 80 { \relative { e'4 e d8 e4 g e2 } }

\recorderTune "Lonely Rolling Star" 160 { \relative { bes2 ees4 f f8 g16 g2 } }

\recorderTune "Windows Error" 160 { \relative { d'16 e g, c,4 } }

\recorderTune "World Bowser" 140 { \relative { bes4 b8 bes8 b16 e8 g4 } }

\recorderTune "Oh Canada" 160 { \relative { e'2 g4. g8 c,2 } }

\recorderTune "Moody" 140 { \relative { ees'4. d2 c8 c8 ees2 f4 d8 d4 c2. } }
