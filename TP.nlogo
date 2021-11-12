breed[comiloes comilao]
breed[Limpadores Limpador]

turtles-own [energia]
Limpadores-own [deposito]

globals [nDep DepositoArmazenamento]

to Setup
  reset-ticks
  set nDep 0
  set DepositoArmazenamento 0
  setup-patches
  setup-turtles




end

;setup agentes
to setup-turtles
  clear-turtles
  create-comiloes nComiloes [
    set shape "bug"
    set color pink
    setxy random-xcor random-ycor
     while [ [pcolor] of patch-here != black]
      [setxy random-xcor random-ycor]
    set heading 90
    set energia nEnergia

  ]

  create-limpadores nLimpadores [
  set shape "triangle"
  set color orange
  setxy random-xcor random-ycor
    while [[pcolor] of patch-here != black]
    [setxy random-xcor random-ycor]
    set heading 0
    set deposito 0
    set energia nEnergia
  ]


end


;setup celulas, comida, lixo normal e lixo toxico, as probabilidades do enunciado foram impostas

to setup-patches
  clear-all
  set-patch-size 15
  reset-ticks
  ask patches [
    if  random 101 + 1 <= ProbRes [
      ifelse random 101 <= 50[
        set pcolor yellow
      ]
      [set pcolor red]

    ]
    if random 101 <= ProbComida [
      set pcolor green
    ]

    if  nDep < nDepositos [
      set nDep nDep + 1
      set pcolor blue
    ]

  ]


end


to Go
  if count comiloes = 0 or ticks = 10000 [stop]
  ;if ticks = 10000 [stop]
  moveComiloes
  moveLimpadores
  ask comiloes [
    morrer
  ]
  ask Limpadores [morrer]

  ask turtles [set energia round(energia)]

  tick

end


;Funcao para o movimento dos comiloes

to moveComiloes
  ask comiloes [
    ; Gerar movimentos aleatórios onde tem 80 % de prob de seguir em frente e 20 % de virar para um dos lados
    ifelse random 101 >= 20 and patch-ahead 1 != nobody[
      ; Controla a próxima patch, se não for amarela ou vermelha (resíduos) pode avançar
      ifelse [pcolor] of patch-ahead 1 != yellow and [pcolor] of patch-ahead 1 != red [
        fd 1
        ; Decrementar energia por movimento
        set energia energia - 1
      ]
      [
        ; Se detetou algum resíduo em frente verificar qual para retirar a quantidade de energia da perceção adequada
        if [pcolor] of patch-ahead 1 = yellow [set energia energia - energia * 0.05]
        if [pcolor] of patch-ahead 1 = red [set energia energia - energia * 0.1]
        ; Aleatoriamente virar para a esquerda ou para a direita, onde primeiro é feita uma verificação da patch-forward da direção que se virar
        ; Se conter lixo vira para trás (left or right 180)
        ifelse random 101 <= 50
        [
          ifelse [pcolor] of patch-left-and-ahead 45 0 != red and  [pcolor] of patch-left-and-ahead 45 0 != yellow [
            left 90
            set energia energia - 1
          ]
          [
            if [pcolor] of patch-left-and-ahead 45 0 = red [set energia energia - energia * 0.1]
            if [pcolor] of patch-left-and-ahead 45 0 = yellow [set energia energia - energia * 0.05]
            left 180
            set energia energia - 1
          ]

        ]
        [
          ifelse [pcolor] of patch-right-and-ahead 45 0 != red and  [pcolor] of patch-right-and-ahead 45 0 != yellow [
            right 90
            set energia energia - 1
          ]
          [
            if [pcolor] of patch-right-and-ahead 45 0 = red [set energia energia - energia * 0.1]
            if [pcolor] of patch-right-and-ahead 45 0 = yellow [set energia energia - energia * 0.05]
            left 180
            set energia energia - 1

          ]
        ]

      ]

    ]

    [
      ifelse random 101 >= 50 [
        left 90
        set energia energia - 1
      ]
      [
        right 90
        set energia energia - 1
      ]
    ]

    ; Condição de controlo que não pode acontecer
    if [pcolor] of patch-here = yellow or [pcolor] of patch-here = red [die]
    ; Se a patch atual for verde então comer
    if [pcolor] of patch-here = green [
      comer

    ]
  ]


end

;Funcao para o movimento dos Limpadores, estes sao agentes com memoria tendo alguma das suas acoes dependendo da capacidade de armazenamento dos residuos
to moveLimpadores
  ask Limpadores[

    ifelse random 101 >= 20 and patch-ahead 1 != nobody and (deposito < nDepositoLimpadores or ([pcolor] of patch-ahead 1 != red and [pcolor] of patch-ahead 1 != yellow))  [
      fd 1
      set energia energia - 1
    ]
  [
    ifelse random 101 >= 50 [
        left 90
        fd 1
        set energia energia - 1
      ] [
        right 90
        set energia energia - 1
      ]

  ]

    if [pcolor] of patch-here = yellow [
      if deposito < nDepositoLimpadores [
        LimparAmarelo
        set deposito deposito + 1
      ]



    ]
    if [pcolor] of patch-here = red[
      if deposito + 2 <= nDepositoLimpadores [
        LimparVermelho
        set deposito deposito  + 1
      ]
    ]

    if [pcolor] of patch-here = blue [
      depositarResiduos

    ]


    if [pcolor] of patch-here = green [
      comerLimpa
    ]


  ]


end
;Impor regras no deposito de residuos por parte dos limpadores
to depositarResiduos

    set DepositoArmazenamento DepositoArmazenamento + deposito
    set energia energia + 10 * deposito
    set deposito 0



end
;Limpar residuos amarelos
to LimparAmarelo

      set deposito deposito + 1
      set pcolor black
      ask one-of patches with [pcolor = black] [
        set pcolor yellow
      ]


end
;Limpar residuos vermelhos
to LimparVermelho
   set deposito deposito + 2
      set pcolor black
      ask one-of patches with [pcolor = black] [
        set pcolor red
      ]

end

;turtles morrem se energia < 0

to morrer
  if energia <= 0 [die]

end

;Funcao default para Comedores comerem, troca a posicao da celula sem afetar o numero inicial imposto de celulas

to comer

     set energia  energia + energiaGanha
      set pcolor black
      ask one-of patches with [pcolor = black] [
        set pcolor green
      ]

end

; Funcao para os limpadores que define uma regra para a restauração de energia quando comem.
to comerLimpa
  ;Se o depósito estiver a mais que metade os limpadores ganham metade de energia ao comer uma célula verde.
  ifelse deposito > nDepositoLimpadores / 2 [set energia  energia + (energiaGanha / 2)]
      [set energia  energia + energiaGanha]
      set pcolor black
      ask one-of patches with [pcolor = black] [
        set pcolor green
      ]

end
@#$#@#$#@
GRAPHICS-WINDOW
555
17
1058
521
-1
-1
15.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
1102
72
1274
105
ProbRes
ProbRes
0
15
5.0
1
1
NIL
HORIZONTAL

SLIDER
1104
108
1276
141
ProbComida
ProbComida
5
20
14.0
1
1
NIL
HORIZONTAL

SLIDER
1106
144
1278
177
nDepositos
nDepositos
1
10
4.0
1
1
NIL
HORIZONTAL

BUTTON
1357
95
1421
128
NIL
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1357
128
1420
161
NIL
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1111
377
1283
410
nComiloes
nComiloes
0
50
50.0
1
1
NIL
HORIZONTAL

SLIDER
1107
242
1279
275
nLimpadores
nLimpadores
0
50
24.0
1
1
NIL
HORIZONTAL

SLIDER
1118
464
1290
497
nEnergia
nEnergia
10
100
100.0
1
1
NIL
HORIZONTAL

MONITOR
128
283
222
328
Comilões
count comiloes
17
1
11

SLIDER
1117
497
1289
530
energiaGanha
energiaGanha
0
50
35.0
1
1
NIL
HORIZONTAL

SLIDER
1110
279
1282
312
nDepositoLimpadores
nDepositoLimpadores
0
10
6.0
1
1
NIL
HORIZONTAL

MONITOR
200
349
330
394
Resíduos Depositados
DepositoArmazenamento
17
1
11

MONITOR
231
282
341
327
Limpadores
count Limpadores
17
1
11

TEXTBOX
1102
37
1333
81
Configuração Ambiente
18
0.0
1

TEXTBOX
1109
206
1310
250
Configuração Limpadores
18
0.0
1

TEXTBOX
1113
350
1324
394
Configuração Comilões
18
0.0
1

TEXTBOX
1113
435
1306
479
Configuração Agentes
18
0.0
1

TEXTBOX
114
218
421
284
Informação do(s) Ambiente / Agentes
18
0.0
1

MONITOR
130
349
187
394
Comida
count patches with [pcolor = green]
17
1
11

MONITOR
132
422
241
467
Resíduos normais
count patches with [pcolor = yellow]
17
1
11

MONITOR
262
423
367
468
Resíduos tóxicos
count patches with [pcolor = red]
17
1
11

TEXTBOX
112
28
342
72
Gráficos do ambiente
18
0.0
1

PLOT
27
61
227
211
Comilões / Limpadores
ticks
Agentes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"limpadores" 1.0 0 -1184463 true "" "plot count Limpadores"
"Comilões" 1.0 0 -13840069 true "" "plot count comiloes"

PLOT
250
58
450
208
Comida / Resíduos
ticks
Patches
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Comida" 1.0 0 -13840069 true "" "plot count patches with [pcolor = green]"
"Resíduo normal" 1.0 0 -1184463 true "" "plot count patches with [pcolor = yellow]"
"Resíduo tóxico" 1.0 0 -2674135 true "" "plot count patches with [pcolor = red]"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment1" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count comiloes</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="nComiloes">
      <value value="10"/>
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ProbComida">
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ProbRes">
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLimpadores">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nDepositos">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nDepositoLimpadores">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nEnergia">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaGanha">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment2" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count Limpadores</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="nLimpadores">
      <value value="10"/>
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ProbComida">
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ProbRes">
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nComiloes">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nDepositos">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nDepositoLimpadores">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nEnergia">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaGanha">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment3" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count comiloes</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="nComiloes">
      <value value="10"/>
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ProbComida">
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nEnergia">
      <value value="25"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLimpadores">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ProbRes">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nDepositos">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nDepositoLimpadores">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaGanha">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment4" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count comiloes</metric>
    <metric>count Limpadores</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="nComiloes">
      <value value="10"/>
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLimpadores">
      <value value="10"/>
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ProbRes">
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ProbComida">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nDepositos">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nDepositoLimpadores">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nEnergia">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaGanha">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment5" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count comiloes</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="nComiloes">
      <value value="10"/>
      <value value="30"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaGanha">
      <value value="10"/>
      <value value="25"/>
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ProbComida">
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nLimpadores">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ProbRes">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nDepositos">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nDepositoLimpadores">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nEnergia">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
