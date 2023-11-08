#import "@preview/polylux:0.3.1": *

#import themes.simple: *

#set text(font: "Inria Sans")

#show: simple-theme.with(footer: [Simple slides])

#title-slide[
  = Keep it simple!
  #v(2em)

  Alpha #footnote[Uni Augsburg] #h(1em)

  July 23
]

#centered-slide[
  == What is a Fourier Transform?
  given a function f(x),\ it's Fourier transform is defined as

  $F(omega) = integral_(-oo)^(oo) f(x)e^(-i omega x) dif x$\
  and the inverse Fourier transform is\
  $f(x) = 1/(2pi) integral_(-oo)^(oo) f(omega)e^(i omega x) dif omega$
]

#slide[
  == What is a Fourier Transform?

  It's a way to transform functions into a different domain.

  #pause

  #lorem(20)
]

#slide[
  == Applications in Computer Science
]

#focus-slide[
  _Focus!_

  This is very important.
]

#centered-slide[
  = Let's start a new section!
]

#slide[
  == Dynamic slide
  Did you know that...

  #pause
  ...you can see the current section at the top of the slide?
]