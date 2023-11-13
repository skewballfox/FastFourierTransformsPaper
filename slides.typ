#import "@preview/polylux:0.3.1": *

#import themes.simple: *

#set text(font: "Inria Sans")

#show: simple-theme.with(footer: [Simple slides])

#title-slide[
  = Fast Fourier Transform
  #v(2em)

  Joshua Ferguson

  //July 23
]

#centered-slide[
  == quick note about polynomials
  Given a polynomial of degree $n$, there are 2 ways to represent it:\
  1. as a vector of coefficients $a_0, a_1, a_2, ... a_n$\
  2. as a set of $n+1$ points $(x_0, y_0), (x_1, y_1), ... (x_n, y_n)$
]

#centered-slide[
  == What is a Fast Fourier Transform?
  It's an algorithm that computes the Discrete Fourier Transform of a sequence of
  numbers.\

  #pause
  This is useful because it allows us to convert a polynomial from one
  representation to the other in $O(n log n)$ time.\

  Computing the FFT of a vector of coefficients gives us the points of the
  polynomial, and computing the inverse FFT of a set of points gives us the
  coefficients of the polynomial.

]

#centered-slide[
  == Applications in (Computer) Science
  - When used in signal processing, it can break down a signal into its
    constituent frequencies. These can then be filtered out or modified and the
    signal can be reconstructed.
  - Because of this it's used heavily in audio processing, image compression,
    radar, sonar, seismology, and more.
]


#slide[
  == history of the FFT
  The history of the FFT is a bit complicated, as is the Fourier Transform\

  - Attribution for the Fourier Transform is often given to Jean-Baptiste Joseph
    Fourier, in a paper published in 1822.
  - The Discrete Fourier Transform was first defined in 1805 by Carl Friedrich
    Gauss, but it was not published until 1866.

  //The Fourier Transform likely originated from the work of Joseph Fourier in
  //1811\(in a paper that wasn't published until 1822\)
]

#centered-slide[
  == history of the FFT (cont.)
  The Fast Fourier Transform was popularized by James Cooley and John Tukey in
  1965, but it was first described by Carl Friedrich Gauss in 1805.\
]

// #centered-slide[
//   == What is a Fourier Transform?
//   given a function f(x),\ it's Fourier transform is defined as

//   $F(omega) = integral_(-oo)^(oo) f(x)e^(-i omega x) dif x$\
//   and the inverse Fourier transform is\
//   $f(x) = 1/(2pi) integral_(-oo)^(oo) f(omega)e^(i omega x) dif omega$
// ]

// #slide[
//   == What is a Fourier Transform?

//   It's a way to transform functions into a different domain.

//   It's often used to transform a function from the time domain into the frequency
//   domain.

//   #pause
//   While most of the signals we encounter in real life are continuous, the process
//   of capturing them digitally is discrete.
// ]

#slide[
  == What is a Discrete Fourier Transform
  Lets define a signal $a_n$ as a sequence of $N$ values $a_0, a_1, a_2, ... a_(N-1)$.

  this signal is periodic so $a_n=a_(n+j N)$ for all $n and j$\ the DFT of $a$ is a sequence $A$ of equal length
  defined as
  $
  A_k = sum_n^(N-1) W_N^(k n) a_n
  $\
  where $W_N^(k n) = e^(i (-2pi n)/N)$ 
]
#slide[
  $W_N^k$for $k=0... N-1$ are the $N$th roots of unity, as they satisfy the
  equation $(W_N^k)^N = 1$

  because powers of roots of unity are periodic (repeat every $N$ steps), their possible values are limited to $N$ distinct points on the unit circle in the complex plane.
  
]
#centered-slide[
  == Discrete Fourier Transform
  it takes $O(N^2)$ time to compute the DFT of a signal of length $N$. For each element of the $N$-length output, you have to compute a sum of $N$ terms.\
]

// #centered-slide[
//   == DFT of a signal of length 2
//   Let's look at the DFT of a signal of length 2.\
//   $
//     W_N = e^(i (-2pi )/2)=e^(-i pi)=-1
//   $
//   $
//     A_k=sum_(n=0)^(1) -1^(k n) a_n = \(-1\)^(k dot 0) + \(-1\)^(k dot 1) = a_0 + (-1)^(k) a_1
//   $
//   $
//     A_0 = a_0 + a_1\
//     A_1 = a_0 - a_1
//   $
// ]
#centered-slide[
  == DFT of a signal of length 4
  Let's look at the DFT of a signal of length 4.\
  $
    W_N = e^(i (-2pi )/4)=e^(-i pi/2)=-i
  $
  $
    A_k=sum_(n=0)^(3) -i^(k n) a_n 
    = a_0 + (-i)^(k) a_1 + (-i)^(2 k) a_2 + (-i)^(3 k) a_3\
  $
  $
    A_0 = a_0 + (a_1 + a_2) + a_3\
    A_1 = a_0 - (i a_1 - a_2) +i a_3\
    A_2 = a_0 - (a_1 + a_2) - a_3\
    A_3 = a_0 + (i a_1 - a_2) - i a_3
  $
]


#slide[
  == Fast Fourier Transform (Cooley-Tukey)
  The Cooley-Tukey algorithm is a divide and conquer algorithm that computes the
  DFT of a signal in $O(N log N)$ time.\

  It does this by splitting the signal into 2 halves, recursively computing the
  FFT of each, and then combining the results.

]
#slide[
  input: a coefficient vector $a$ of length $N$ where $N$ is a power of 2\
  output: the DFT of $a$

  let n = length(a)\
  if n == 1:\
  #" return a"

  let nth_root = $e^((2pi i)/n)$\
  let even = FFT([$a_0$, $a_2$, $a_4$, ...])\
  let odd = FFT([$a_1$, $a_3$, $a_5$, ...])\

  let result = vector of length n\
  for k = 0 to n/2 - 1:\
  #" " result[k] = even[k] + (nth_root^k \* odd[k])\
  #" " result[k+n/2] = even[k] - (nth_root^k \* odd[k])\
  return result
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