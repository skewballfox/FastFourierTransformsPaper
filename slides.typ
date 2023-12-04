#import "@preview/polylux:0.3.1": *

#import themes.simple: *

#set text(font: "Inria Sans")

#show: simple-theme.with(footer: [Master's Comprensive Exam])
#title-slide[
  = Part1
  = Ergonomic Systems Programming
  #v(2em)
  == Comparing the developer experience of Rust and C for Systems programming
]

#slide[
  == What is Systems Programming?

  - Software that either directly interacts with hardware or is close to the
    hardware.
  - Software that provides services to other software
  #pdfpc.speaker-note(
    "Examples: Operating Systems, device drivers, embedded systems, databases, browsers, computational libraries, etc.",
  )
]

#slide[
  == What is Developer Experience (DevX)?
  #figure(
    image(".attachments/Pasted image 20231124170829.png", width: 53%),
    caption: [
      Core dimensions of DevX @nodaDevExWhatActually2023
    ],
  )
  #pdfpc.speaker-note(
    ```md
      developer experience encompasses how developers feel about and think about their work. It's a combination of the three core dimensions:
      - Feedback loops -- the speed and quality of responses to actions performed
      - Cognitive load -- the amount of mental processing required to perform a task
      - Flow State -- the ability to be fully immersed in a task

      These are effected by the language, the tooling, and the ecosystem. While there are organizational factors that can effect these, they are out of scope

      ```,
  )
]

#slide[
  == What is Rust?

  - A systems programming language that is memory safe, performant, and has a focus
    on developer experience
  - It uses the concepts of ownership and lifetimes to ensure memory safety at
    compile time, without the need for a garbage collector
  - support for testing, documentation, and package management are built into the
    language
  #pdfpc.speaker-note(
    ```md
      - it is a mix of imperative and functional programming, and it's expression based
      - Compiled programs are statically linked, so they can be distributed as a single binary
      - Performance is comparable to C and C++
      - The process of publishing a package is built into cargo, and documentation is generated automatically
      - Cargo is extensible, so the community often adds custom subcommands for tasks related to rust development
      ```,
  )
]

#slide[
  == Why is this important?
  - Systems programming is important for the development of software that is
    critical to society
  - The developer experience of a language effects not only the productivity of the
    developers, but also the quality of the software
  - Speaking from personal experience, The likelihood of starting a project in a
    language is inversely proportional to the difficulty of setting up a development
    environment
  #pdfpc.speaker-note(
    ```md
      - Let's ignore the fact that Rust is memory safe for a moment, and the statistics that show that memory safety bugs are the most common cause of security vulnerabilities in software
      - If a language is difficult to use, developers will be less productive, and will be more likely to make mistakes
      - If humans have a finite cognitive capacity, and a language incurs a higher cognitive burden, then less of that capacity is available for the task at hand
      - rust has a way of lowering the barrier to entry for developers in this space, and it's worth looking at how it does that
      ```,
  )
]

#slide[
  == Research Questions
  1. What development friction exist for developers working on systems programming
    projects, such as the linux kernel?
  2. How does Rust's language design effect the cognitive load of developers in
    systems programming?
  3. How does the workflow (use of tools for common task) differ between the two
    langauges?
  #pdfpc.speaker-note(
    ```md
      - The First question aims to get a better understanding of the problems in this space, such as onboarding new developers
      - The second question aims to understand how the language itself effects developer velocity
      - The third attempts to compare the tooling, the level of integration, and ecosystem between the two languages
      ```,
  )
]

#slide[
  == Problems with the Research Questions
  - it was difficult to find papers that examined the developer experience of C
    specifically
  - The scope of my investigation turned out to be both too broad and too narrow,
    because the variety of the problem space
  #pdfpc.speaker-note(
    ```md
      - One problem I ran into early on is regardless of the search engine used, using C and developer experience tended to return results related to the experience level of developers. This improved once I started using terms like "onboarding" and "cyclomatic complexity"
      - Systems programming is rarely used as a term in research papers, so I had to narrow it down by using terms such as "kernel", "embedded", "drivers", "browsers", etc.
      - Furthermore, finding papers that intersected developer experience and one of those terms was difficult
      - It would have been easier if I was using more non-academic sources, such as developer blogs, though I wanted to avoid that as much as possible
      ```,
  )
]

#slide[
  == Search Terms
  - Developer Experience, DevEx, Onboarding, Cognitive Load
    - Cyclomatic Complexity, Static Analysis
  - Systems Programming, Embedded, Kernel, Drivers, Browsers, Network
  - Rust, C, C Programming Language
  #pdfpc.speaker-note(
    ```md
      - I started with the terms developer experience in combination with either rust or c, but I noticed pretty quickly that that combination was pretty useless due to the number of results related to the experience level of developers
      - Cognitive Load similarly returned a lot of results related to the cognitive load of learning a new language, onboarding favored results not directly tied to the language
      - After I discovered the paper on DevEx, and how it defined the term, I swapped out those terms with Static Analysis, Cyclomatic Complexity
      - I started with systems programming, but that was too broad, so I narrowed it down to embedded, kernel, drivers, browsers, and network
      ```,
  )
]
#slide[
  = RQ1: Developer Friction in Systems Programming
  - high cognitive burden to ensure correctness
  - Prerequisite knowledge and experience is often irreplaceable
  - Static analysis tools require tuning per application, and they often have to
    assume correctness of dependencies@nosedaRustSecureIoT2022
  - oboarding new developers is often an anxiety ridden process for existing
    maintainers @traceyGradingCurveHow2023
  - for HPC, it's hard to write code that is scalable and
    maintainable@costanzoPerformanceVsProgramming2021
  #pdfpc.speaker-note(
    ```md
      - Least covered Question, it was difficult to identify sources of friction unique to systems programming.
      - all papers gave the impression of high cognitive burden and requirement of experience
      - a paper comparing C and rust for secure IoT development mentioned the limitations of static analysis tools in c and C++
      - paper comparing vulnerabilities in first commmits between rust and C++ talked about the onboarding process
      ```,
  )
]

#slide[
  == RQ2: How does rust design affect DevEx?
  The initial learning curve is much steeper than C.
  - Concept of Ownership and lifetimes relatively novel
  - It's expression based, hybrid between functional and imperative
  - It isn't (fully) object oriented

  #pdfpc.speaker-note(
    ```md
      - there were languages that use ownership before (cyclone), but this is most users first encounter
      - a survey responder from one paper which explored difficulties in developers learning new language described it as "a fairly alien concept"
      - part of the thing new users struggle with is that it is heavily influenced by functional programming
      - furthermore, attempting to do things in an object oriented way often leads to fights with the borrow checker
      - let's look at the papers mentioned in RQ1 slide
      ```,
  )
]

#slide[

  Rust's type system allows for moving more verification of correct implementation
  to compile time
  - This is because the type system can be used to enforce invariants that would
    otherwise be checked at runtime
  - While this example is related embedded systems, this was a common theme for
    papers exploring using rust for drivers and network protocols
  ```rs
    fn uart_init(baudrate: u32,
                  tx: GpioOutput, rx: GpioInput) -> Uart {...}
    fn gpio_init_output(pin: GpioUninit) -> GpioOutput {...}
    ```
  #pdfpc.speaker-note(
    ```md
      - a UART driver at initilization would require the gpio
       pin to already be initialized.
      - in this example, as the GpiOutput type is created by gpio_init_output, the developer is forced to initialize
      the gpio output pin prior to
      ```,
  )

]
#slide[
  When comparing the c++ and rust implementations of the same Components, First
  time contributors were 70 times more likely to introduce a vulnerability in C++
  than in rust

  #figure(image(".attachments/RustvsCppVulnCommits.png", width: 90%))
  #pdfpc.speaker-note(
    ```md
      - while this is more related to memory safety, it does impact the developer experience of existing maintainers
      - This was including CVEs in rust that would not have existed in C++ because of the community's tendency to  report soundness bugs as CVEs
      - soundness bugs are violations of the memory safety guarantees of (safe) rust, it's a source of undefined behavior. These are often reported as CVEs, even though they are not security vulnerabilities, and would not be reported as such in C++
      ```,
  )
]

#slide[

  Compared against C, C++ and a few higher level languages, rust had a lower
  cyclomatic complexity than c, c++, but higher than languages like python and
  typescript
  - Similarly Rust filled a similar role in Halstead Metrics
  - rust was the most structured as measured by NOM and NEXIT metrics
  - had the lowest COGNITIVE complexity score out of any language
  #pdfpc.speaker-note(
    ```md
      - Cyclomatic complexity is a measure of the number of linearly independent paths through a program
      - Halstead Volume for example is a function of the number of unique operators and operands, and the total number of operators and operands
      - NOM number of methods, NEXIT number of exits
      - Cognitive complexity is weighted sum of a programs
      components, influenced by breaks in linear flow(if, match), breaks in linear flow, and nesting
      ```,
  )
]

#slide[
  == RQ2: pt 3 issues with compile time
  The length of feedback loops is one of the three core dimensions of developer
  experience
  - Rust's compile times tend to be a source of frustration for larger projects
  - compile times suffer when making heavy use of generics, user defined types and
    macros
  #pdfpc.speaker-note(
    ```md
      - Rust creates statically compiled binaries, so at each
      stage of the build process, the entire dependency tree must be compiled
      - while it makes use of incremental compilation, it's not as effective as it could be
      - part of the reason for this is that the rustc frontend for llvm is single threaded, though this has
      been added in nightly
      ```,
  )
]

#slide[
  = RQ3: differences in workflow
  high level differences:
  - in C there are tools for every task, but they are often not integrated
  - in rust, there is a single tool for most tasks, and the community tends to
    create subcommands for tools related to rust development
  //   #table(
  //   columns: (auto, auto, auto),
  //   inset: 10pt,
  //   align: horizon,
  //   [], [*C*], [*rust*],
  //   [build system], [make, cmake, ninja, meson, bazel, etc], [cargo],
  //   [package manager], [system, manual], [cargo],
  //   [documentation], [doxygen, sphinx, etc], [rustdoc/cargo],
  //   [testing], [criterion, unity, ctest], [cargo],
  //   [linting], [clang-tidy, cppcheck, flint, splint, etc], [`cargo clippy`],
  // )
  #pdfpc.speaker-note(
    ```md
      - rust has a single tool for most tasks, and the community tends to create subcommands for tools related to rust development
      - There are community plugins for tasks such as fuzzing, model checking, profiling,
      - In Rust documentation is generated for all public code automatically on publication of a crate (library), and is hosted on docs.rs
      - Doc strings are 3 slash, written in markdown and support code blocks which also function as tests
      ```,
  )
]

#slide[
  =
  static analysis is built into the compiler. It's how the borrow checker works
  - warnings and compiler errors are often accompanied by suggestions
  - these can be automatically applied with `cargo fix`
  - rust-analyzer (the rust language server) can show these suggestions in real time
]

#slide[
  ==
  the effect is there seems a higher level of integration between tools in rust,
  and there is more focus on code reuse
  - all dependencies are at least somewhat documented.
  - it's easy to publish a crate, and at the moment there are 132,254 published
    crates(binaries and libraries)

  #pdfpc.speaker-note(```md
    - this is up from 129,496 as of about a month ago
    - you have code reuse in C, but IME it's major libraries
    ```)
]

#slide[
  = Conclusion
  Systems programming is inherently difficult.

  - The general takeaway from papers regarding C is that it's difficult to write
    correct code, and it's difficult to onboard new developers. Prerequisite
    knowledge and experience is often irreplaceable

  - Rust has a higher initial learning curve, but it allows for moving more
    verification of correct implementation to compile time
  - Rust's tooling is more integrated, and there is more focus on code reuse

  #pdfpc.speaker-note(
    ```md
      - Getting things right is critical and it seems like the current solution is to put more of the onus on the developer
      - New contributors are less likely to introduce vulnerabilities
      - rust is one of the first languages to offer this quality of developer experience while still providing low level control
      - These features could lower the barrier to entry for new developers in the space
      ```,
  )
]

#slide[
  = Future Work
  Questions I had after reading these papers
  - Does Rust's built in testing and documentation lead to developers writing more
    tests and documentation?
  - For developers who have experience with both, does rust's tooling lead to a
    higher level of productivity?
  - I wonder how the "information density per expression" of rust compares to C and
    C++
  - Is there a way to measure the differences in complexity in ported or replaced
    components?
  #pdfpc.speaker-note(
    ```md
      - The Paper comparing different measures of complexity in rust use halstead volume
      - In the paper examing the complexity of rust and other languages, they were using halstead volume as an approximation of the information content of a program. I wonder ho
      - The last one draws a bit from my own experience, I've noticed a tendency in people to do things like avoid clones because of the explicitness or keep a single copy of a string in memory because, in a way, the language is set up like a logic puzzle. I've also noticed from time spent on phoronix and hacker news, that people who are developing in C prefer starting with the simplest implementation (less to go wrong).
      ```,
  )

]

#title-slide[
  = Fast Fourier Transform
  #v(2em)

  Joshua Ferguson

  //July 23
]

#centered-slide[
  == quick note about polynomials
  Given a real numbered polynomial of degree $n$, there are 2 ways to represent
  it:\
  1. as a vector of coefficients $a_0, a_1, a_2, ... a_n$\
  2. as a set of $n+1$ points $(x_0, y_0), (x_1, y_1), ... (x_n, y_n)$
]

#slide[
  == What is a Fast Fourier Transform?
  It's an algorithm that computes the Discrete Fourier Transform of a sequence of
  numbers.
  - This is useful because it allows us to convert a polynomial from one
    representation to the other in $O(n log n)$ time.
  - Computing the FFT of a vector of coefficients gives us the points of the
    polynomial, and computing the inverse FFT of a set of points gives us the
    coefficients of the polynomial.
  #pdfpc.speaker-note(
    ```md
      - While it's not mentioned on the next slide, this allows us to do polynomial multiplication in $O(n log n)$ time.
      ```,
  )

]

#slide[
  == Applications in (Computer) Science
  - When used in signal processing, it can break down a signal into its constituent
    frequencies. These can then be filtered out or modified and the signal can be
    reconstructed.
  - Because of this it's used heavily in audio processing, image compression, radar,
    sonar, seismology, and more.

]

#slide[
  = history of the FFT
  The history of the FFT is a bit complicated, as is the Fourier Transform\

  - Attribution for the Fourier Transform is often given to Jean-Baptiste Joseph
    Fourier, in a paper published in 1822.
  - The Discrete Fourier Transform was first defined in 1805 by Carl Friedrich
    Gauss, but it was not published until 1866.

  //The Fourier Transform likely originated from the work of Joseph Fourier in
  //1811\(in a paper that wasn't published until 1822\)
]

#centered-slide[
  The Fast Fourier Transform was popularized by James Cooley and John Tukey in
  1965, but it was first described by Carl Friedrich Gauss in 1805.
  #pdfpc.speaker-note(
    ```md
      - It wasn't until after the publication of the Cooley-Tukey paper that Gauss's work was discovered
      ```,
  )

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

  this signal is periodic so $a_n=a_(n+j N)$ for all $n and j$\ the DFT of $a$ is
  a sequence $A$ of equal length defined as
  $
  A_k = sum_n^(N-1) W_N^(k n) a_n
  $\
  where $W_N^(k n) = e^(i (-2pi n)/N)$
  #pdfpc.speaker-note(
    ```md
      - the kth element of the output is the sum of all terms multiplied by the kth root of unity
      ```,
  )
]
#slide[
  $W_N^k$for $k=0... N-1$ are the $N$th roots of unity, as they satisfy the
  equation $(W_N^k)^N = 1$
  - because powers of roots of unity are periodic (repeat every $N$ steps), their
    possible values are limited to $N$ distinct points on the unit circle in the
    complex plane.

  #figure(image(".attachments/roots_of_unity.png", width: 65%), caption: [
    The roots of unity for N=2,4,8 @heckbert1995fourier
  ])
  #pdfpc.speaker-note(
    ```md
      - it's useful to think of them as slices of a circle, for the 4th root of unity, you have 4 slices of a circle, each of which is 90 degrees
      ```,
  )

]

#centered-slide[
  = Discrete Fourier Transform
  it takes $O(N^2)$ time to compute the DFT of a signal of length $N$. For each
  element of the $N$-length output, you have to compute a sum of $N$ terms.\
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
  = Fast Fourier Transform (Cooley-Tukey)
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
  #pdfpc.speaker-note(```md
    - this is a recursive implementation of the Cooley-Tukey algorithm
    - for the IFFT the only diffference is the nth_root is
    equal to (1/n)* e**(-2*pi*1j/n)
    ```)
]
#centered-slide[
  == Comparison of DFT and (Cooley-Tukey) FFT
  #table(
    columns: (1fr, auto, auto, auto),
    inset: 10pt,
    //align: [4,3],
    rows: (4),
    [size of n],
    [*DFT Directly*\ $4 N^2$],
    [*FFT*\ $2 N log N$],
    [speedup],
    [2\ 4\ 8],
    [16\ 64\ 256],
    [4\ 16\ 48],
    [4\ 4\ 5],
    [1024\ 65,536],
    [4,194,304\ $1.7 dot 10^10$],
    [20,480\ $2.1 dot 10^6$],
    [205\ $~10^4$],
  )
]
#slide[
  = Fast Fourier Transform Algorithms
  There are many different FFT algorithms, each suited to different situations.\
  - Rader's algorithm is useful for prime length inputs
  - Good-Thomas algorithm (PFA) is useful when into two vectors whose lengths are
    relatively prime
  - Radix3 is useful for inputs that are powers of 3
  - Bluestein's algorithm is useful for inputs of arbitrary length
  - This is nowhere near an exhaustive list
  #pdfpc.speaker-note(
    ```md
      Algorithms may choose a different base that technically performs more operations, but is faster because of available hardware instructions.
      ```,
  )
]

#slide[
  == FFT Implementations
  Given that which algorithm is optimal is often context dependent, Libraries that
  provide FFT implementations often employ a planner that chooses the best
  (hybrid) algorithm for the given input and the hardware.
  @frigoDesignImplementationFFTW32005

  - The plan is cached so that the next time the same input is given, the algorithm
    can be immediately executed.
  - FFTW is a popular library that does this. It's used internally by numpy, scipy
]

// #slide[
//   == limitations of FFT algorithms

 // ]

// #slide[
//   = Looping Back Around
//   FFTW3 is sort of the standard for computing FFTs in every language. It's primarily written in C, and was for a long time the fastest FFT implementation available.
//   - at least on one architecture (Arm) that is no longer the case, where it was benchmarked against rustfft and custom fft implementations
//   - rustfft was faster by 37% on average, and 45% more energy efficient
//   #figure(
//     image(".attachments/FFTBench.png", width: 90%)
//   )
//   #pdfpc.speaker-note(```md
//   - in the early days of writing an mfcc library for rust, I had a dev that was rather insistent on using FFTW3, there was no way
//   - why this is significant is that the C in FFTW is generated automatically, and it requires specialized tools to compile and contribute.
//   ```)
// ]

#slide[
  = Sources
  #bibliography("MastersExam.bib")
]