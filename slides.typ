#import "@preview/polylux:0.3.1": *

#import themes.simple: *

#set text(font: "Inria Sans")

#show: simple-theme.with(footer: [Simple slides])
#title-slide[
  = Part1
  = Ergonomic Systems Programming
  #v(2em)
  == Comparing the developer experience of Rust and C for Systems programming
]

#slide[
  == What is Systems Programming?
  - Software that either directly interacts with hardware or is close to the hardware.
  - Software that provides services to other software
  #pdfpc.speaker-note("Examples: Operating Systems, device drivers, embedded systems, databases, browsers, computational libraries, etc.")
]


#slide[
  == What is Developer Experience (DevX)?
  #figure(
    image(".attachments/Pasted image 20231124170829.png", width: 53%),
    caption: [
      Core dimensions of DevX @nodaDevExWhatActually2023
    ]
  )
  #pdfpc.speaker-note(```md
  - Feedback loops -- the speed and quality of responses to actions performed
  - Cognitive load -- the amount of mental processing required to perform a task
  - Flow State -- the ability to be fully immersed in a task

  These are effected by the language, the tooling, and the ecosystem. While there are organizational factors that can effect these, they are outside the scope of this talk
  
  ```)
]

#slide[
  == What is Rust?
  - A systems programming language that is memory safe, performant, and has a focus on developer experience
  - It uses the concepts of ownership and borrowing to ensure memory safety at compile time, without the need for a garbage collector 
  - support for testing, documentation, and package management are built into the language
  #pdfpc.speaker-note(```md
  - Compiled programs are statically linked, so they can be distributed as a single binary
  - Performance is comparable to C and C++
  - The process of publishing a package is built into cargo, and documentation is generated automatically
  - Cargo is extensible, so the community often adds custom subcommands for tasks related to rust development
  ```)
]

#slide[
  == Why is this important?
  - Systems programming is important for the development of software that is critical to society
  - The developer experience of a language effects not only the productivity of the developers, but also the quality of the software
  - Speaking from personal experience, The likelihood of starting a project in a language is inversely proportional to the difficulty of setting up a development environment
  #pdfpc.speaker-note(```md
  - Let's ignore the fact that Rust is memory safe for a moment, and the statistics that show that memory safety bugs are the most common cause of security vulnerabilities in software
  - If a language is difficult to use, developers will be less productive, and will be more likely to make mistakes
  - If humans have a finite cognitive capacity, and a language incurs a higher cognitive burden, then less of that capacity is available for the task at hand
  - rust has a way of lowering the barrier to entry for developers in this space, and it's worth looking at how it does that
  ```)
]

#slide[
  == Research Questions
  - What development friction exist for developers working on systems programming projects, such as the linux kernel?
  - How does Rust's language design effect the cognitive load of developers in systems programming?
  - How does the workflow (use of tools for common task) differ between the two langauges?
  #pdfpc.speaker-note(```md
  - The First question aims to get a better understanding of the problems in this space, such as onboarding new developers
  - The second question aims to understand how the language itself effects developer velocity
  - The third attempts to compare the tooling, the level of integration, and ecosystem between the two languages
  ```)
]

#slide[
  == Problems with the Research Questions
  - it was difficult to find papers that examined the developer experience of C specifically
  - The scope of my investigation turned out to be both too broad and too narrow, because the variety of the problem space
  #pdfpc.speaker-note(```md
  - One problem I ran into early on is regardless of the search engine used, using C and developer experience tended to return results related to the experience level of developers. This improved once I started using terms like "onboarding" and "cyclomatic complexity"
  - Systems programming is rarely used as a term in research papers, so I had to narrow it down by using terms such as "kernel", "embedded", "drivers", "browsers", etc.
  - Furthermore, finding papers that intersected developer experience and one of those terms was difficult
  - It would have been easier if I was using more non-academic sources, such as developer blogs, though I wanted to avoid that as much as possible
  ```)
]

#slide[
  == Included Papers

]

#slide[
  == Demographics of the Papers

]
#slide[
  == RQ1: Developer Friction in Systems Programming
  - high cognitive burden to ensure correctness
  - Prerequisite knowledge and experience is often irreplaceable
  - Static analysis tools require tuning per application, and they often have to assume correctness of dependencies@nosedaRustSecureIoT2022
  - oboarding new developers is often an anxiety ridden process for existing maintainers @traceyGradingCurveHow2023
  - for HPC, it's hard to write code that is scalable and maintainable@costanzoPerformanceVsProgramming2021
  #pdfpc.speaker-note(```md
  - Least covered Question, it was difficult to identify sources of friction unique to systems programming.
  - all papers gave the impression of high cognitive burden and requirement of experience
  - a paper comparing C and rust for secure IoT development mentioned the limitations of static analysis tools in c and C++
  - paper comparing vulnerabilities in first commmits between rust and C++ talked about the onboarding process
  ```)
]

#slide[
  == RQ2: How does rust design affect DevEx?
  - The initial learning curve is much steeper than C.
  - Concept of Ownership and lifetimes relatively novel
  - It's expression based, hybrid between functional and imperative
  - It isn't (fully) object oriented
  
  #pdfpc.speaker-note(```md
  - there were languages that use ownership before (cyclone), but this is most users first encounter
  - part of the thing new users struggle with is that it is heavily influenced by functional programming 
  - furthermore, attempting to do things in an object oriented way often leads to fights with the borrow checker 
  ```)
]

#slide[
  == RQ2 pt 2
  - In the context of embedded systems, Rust's type system allows for moving more verification of correct implementation to compile time
  ```rs
  fn uart_init(baudrate: u32, 
                tx: GpioOutput, rx: GpioInput) -> Uart {...}
  fn gpio_init_output(pin: GpioUninit) -> GpioOutput {...}
  ```
  #pdfpc.speaker-note(```md
  - a UART driver at initilization would require the gpio
   pin to already be initialized. 
  - in this example, as the GpiOutput type is created by gpio_init_output, the developer is forced to initialize
  the gpio output pin prior to 
  ```)

]
#slide[
  
  
]

#title-slide[
  = Fast Fourier Transform
  #v(2em)

  Joshua Ferguson

  //July 23
]

#centered-slide[
  == quick note about polynomials
  Given a real numbered polynomial of degree $n$, there are 2 ways to represent it:\
  1. as a vector of coefficients $a_0, a_1, a_2, ... a_n$\
  2. as a set of $n+1$ points $(x_0, y_0), (x_1, y_1), ... (x_n, y_n)$
]

#centered-slide[
  == What is a Fast Fourier Transform?
  It's an algorithm that computes the Discrete Fourier Transform of a sequence of
  numbers.\

  This is useful because it allows us to convert a polynomial from one
  representation to the other in $O(n log n)$ time.\

  Computing the FFT of a vector of coefficients gives us the points of the
  polynomial, and computing the inverse FFT of a set of points gives us the
  coefficients of the polynomial.
  // While it's not mentioned on the next slide, this allows us to do polynomial
  // multiplication in $O(n log n)$ time.

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
  - because powers of roots of unity are periodic (repeat every $N$ steps), their possible values are limited to $N$ distinct points on the unit circle in the complex plane.

  #figure(
    image(".attachments/Pasted image 20231113133723.png", width: 65%),
    caption: [
      The roots of unity for N=2,4,8 @heckbert1995fourier
    ]
  )
  
]

#centered-slide[
  == Discrete Fourier Transform
  it takes $O(N^2)$ time to compute the DFT of a signal of length $N$. For each element of the $N$-length output, you have to compute a sum of $N$ terms.\
]

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
  FFT of each, and then combining the results. it requires $O(N)$ extra space
  $
  T(N) = 2 T(N/2) + O(N)
  $
  

]
#slide[
  
  ```py
  def FFT(a: NDArray[complex]) -> NDArray[complex]:
      n: int = len(a) # n is a power of 2
      if n == 1:
          return a
      nth_root: complex = e**((2*pi*1j)/n)
      even: NDArray[complex] = FFT(a[::2])
      odd: NDArray[complex] = FFT(a[1::2])
      result: NDArray[complex] = np.zeros(n, dtype=complex)
      for k in range(n//2):
          result[k] = even[k] + (nth_root**k * odd[k])
          result[k+n//2] = even[k] - (nth_root**k * odd[k])
      return result
  ```
]
#centered-slide[
  == Comparison of DFT and (Cooley-Tukey) FFT
  #table(
  columns: (1fr, auto, auto, auto),
  inset: 10pt,
  //align: [4,3],
  rows: (4),
  [size of n], [*DFT Directly*\ $4 N^2$], [*FFT*\ $2 N log N$], [speedup],
  
  [2\ 4\ 8],[16\ 64\ 256],[4\ 16\ 48], [4\ 4\ 5],
  
  [1024\ 65,536],[4,194,304\ $1.7 dot 10^10$],[20,480\ $2.1 dot 10^6$], [205\ $~10^4$]
  
 
)
]
#slide[
  == Fast Fourier Transform Algorithms
  There are many different FFT algorithms, each suited to different situations.\
  - Rader's algorithm is useful for prime length inputs
  - Good-Thomas algorithm (PFA) is useful when into two vectors whose lengths are relatively prime
  - Radix3 is useful for inputs that are powers of 3
  - Bluestein's algorithm is useful for inputs of arbitrary length
  - This is nowhere near an exhaustive list
  // Algorithms may choose a different base that technically performs more
  //operations, but is faster because of available hardware instructions.
]

#slide[
  == FFT Implementations
  - Given that which algorithm is optimal is often context dependent, Libraries
    that provide FFT implementations often employ a planner that chooses the best (hybrid) algorithm for the given input and the hardware. @frigoDesignImplementationFFTW32005

  - The plan is cached so that the next time the same input is given, the
    algorithm can be immediately executed.
  - FFTW is a popular library that does this. It's used internally by numpy, scipy
]


// #slide[
//   == limitations of FFT algorithms

  
// ]

#slide[
  = Useful YouTube videos
  //normally I don't recommend youtube videos for learning something, but there 
  //is a visual component to how and why the FFT works that text is a poor medium for
  - The Remarkable Story Behind The Most Important Algorithm Of All Time, by Veritasium //history of FFT, developed to detect underground nuclear tests
  - The Fast Fourier Transform (FFT): Most Ingenious Algorithm Ever?, by Reducible //goes into the math behind the FFT, and a bit about Fourier transforms
  - Divide and Conquer: FFT, by MIT Open Courseware //Probably start with this if you don't mind an hour and 20 minute lecture, it's the only one that is 
  //geared towards CS students and doesn't use a ton of signal processing and physics terminology
]

#slide[
  = Sources
  #bibliography("MastersExam.bib")
]