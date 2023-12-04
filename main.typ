#import "template.typ": *
#show: ieee.with(
  title: "Fast Fourier Transforms",
  abstract: [
    In this paper, we delve into the realm of Fast Fourier Transforms (FFTs), a
    family of algorithms employed for computing the Discrete Fourier Transform
    (DFT). Recognizing the impracticality of direct DCT computation due to its $O(N^2)$ time
    complexity, we explore various FFT algorithms, providing a comprehensive
    comparison of their efficiency. Our objective is to analyze these algorithms in
    terms of their time and space complexities. We will also discuss the limitations
    of FFTs, explore some of the libraries for computing FFTs, and discuss some of
    the many applications of FFTs.
  ],
  authors: ((
    name: "Joshua Ferguson",
    department: [Bagley College of Engineering],
    organization: [Mississippi State University],
    location: [Starkville, MS],
    email: "joshua.ferguson.273@gmail.com",
  ),),
  index-terms: (
    "Fast Fourier Transforms",
    "FFTs",
    "Discrete Fourier Transforms",
    "Algorithms",
  ),
  bibliography-file: "refs.bib",
)

// 1. You are writing a survey paper on a class of algorithms of your choice. You must do an
// in-depth analysis of the algorithms of that class and present your paper from a critical
// point of view.
// - The emphasis will be on discussing their time complexity (and possibly space complexity
// as well) – upper bounds, lower bounds, and asymptotic tight bounds.
// - Describe the motivation for developing this class of algorithms. Where are they used?
// - Describe the historical development of these algorithms and discuss the advantages and
// disadvantages of using one versus another.
// - What observations and special techniques led to successively obtaining better solutions?
// - Discuss situations in which using one algorithm is better than using another one for the
// same problem and give justification.
// - What is the significance and impact of developing these algorithms?
// - Present the conclusions of your study. What lessons have you learned?

// In both cases, the paper must contain:
// - Motivation for the study
// - Discussions of these algorithms from a critical point of view
// - Significance and impact
// - Conclusions
// Recommended length of the paper: 5-10 pages (including bibliography)
// Style: ACM or IEEE Computer Society.

= Introduction

The Fast Fourier Transform (FFT) is a family of algorithms for computing the
efficiently performing a DFT. First developed as a way to detect underground
bomb tests from seismic data, it's an algorithm that is ubiquitous in signal
processing, image processing, and many other fields. In order to understand the
FFT, and how it functions, we will first need to provide some background on the
DFT and Fourier Transforms in general.

= The Fourier Transform and Discrete Fourier Transform
Fourier transforms are a set of mathematical operations that decompose a
function into its constituent frequencies. It was originally developed by Joseph
Fourier in a paper published in 1822, where he showed that any periodic function
could be represented as a sum of simple sine waves. The purpose of the Fourier
Transform is to map an input function to a new representation, a set of sines
and cosines that describe the frequency content of the original function. Each
Fourier Transform has an inverse that maps it's input to the domain of the
original function. The Fourier Transform of a function $f(x)$ is defined as: $ F(omega) = integral_(-oo)^(oo) f(x) e^{-i omega x} dif x $ <DFT> with
it's inverse being: $ f(x)=(1/2pi) integral_(-oo)^(oo) F(omega)e^(i omega x) dif omega $

The Discrete Fourier Transform (DFT) is a discrete version of the Fourier
Transform. Whereas the Fourier Transform is defined over a continuous domain,
the DFT takes a finite number of samples of a function and maps them to an equal
number of discrete frequencies. Let $a_n$ be a periodic signal of $N$ complex
numbers defined as $a_n=a_0,a_1,...,a_(N-1)$ where $a_n =a_(n+j N) forall n,j$
The DFT is defined as: $ A_k = sum_(n=0)^(N-1) a_n W_N^(k n) $ with it's inverse
being: $ a_n = (1/N) sum_(k=0)^(N-1) A_k W^(-k n) $ where $W_N = e^(-i (2pi n)/N)$ defines
the group of $N$th roots of unity. The only difference between the DFT and it's
inverse is the sign of the exponent in $W_N$, as well as the $1/N$ normalization.

=== The Nth Root of Unity <n-roots>
the $N$th root of unity is a set of $N$ complex numbers where $(W_N^k)^N=1$ for
all $k$, and $W_N^k=W_N^(k+j N)$ for all $k,j$. That is to say, they are
periodic with period $N$. Visually, the $N$th roots of unity are the $N$ equally
spaced points on the unit circle in the complex plane. Starting at $1$, the
points are spaced $2pi/N$ radians apart, here is an example of the 8th roots of
unity:

#figure(image(".attachments/roots_of_unity.png"), caption: [
  The roots of unity for N=2,4,8 @heckbert1995fourier
])

When used in the DFT, the $N$th roots effectively rotate the values of the input
signal in the complex plane.

=== Issues with direct computation of the DFT
The DFT is impractical to compute directly as it requires $4N^2$ floating point
operations.

= Cooley-Tukey FFT

The DFT is impractical to compute directly as it requires $4N^2$ floating point
operations. It wasn't until Cooley and Tukey published their paper in 1965 that
DFTs were usable in practice.

The Cooley-Tukey FFT was the "first" FFT algorithm, and was published in 1965 by
James Cooley and John Tukey. It is a divide and conquer algorithm that makes use
of the symetries of the DFT to reduce the number of operations required from $4N^2$ to $2N log N$.
If $N$ in @DFT is a power of 2, and thus can be factored into $N=N_1 N_2$, we
can break $k,j$ into $k=k_1+k_2 N_1$ and $n=n_1 N_2 + j_2 $, and rewrite it as
$ A[k_1 + k_2 N_1] =\ sum_(n_2=0)^(N_2-1) W_(N_2)^(n_2 k_2) ( W_(N)^(n_2 k_1) sum_(n_1=0)^(N_1-1) a[n_1 N_2 + n_2] W_(N_1)^(n_1 k_1) ) $ <cooley-tukey>

This computes $N_2$ DFTs of length $N_1$, multiplies the result by $W_(N_2)^(n_2 k_2)$ and $W_(N)^(n_2 k_1)$,
and then computes a final DFT of length $N_2$ on the result. The computation
happens recursively, with the base case being $N=1$, which is just the identity
function.@frigoDesignImplementationFFTW32005

The three roots of unity $W_(N)^(n_2 k_1)$,$W_(N_2)^(n_2 k_2)$, and $W_(N_1)^(n_1 k_1)$ are
collectively known as the "twiddle factors". The reason $W_(N)^(n_2 k_1)$ is
used is to account for offsets in the time(or input) domain due to the
separation into smaller DFTs.

If $N_1$ or $N_2$ are bounded, they are often referred to as the "radix". In the
original Cooley-Tukey FFT, $N_1=2$ and $N_2=N/2$, and thus the radix is 2. In
modern FFTs, the radix is often 4, 8, or 16. While these technically result in a
higher number of operations (though still $O(N log N)$), they are often faster
in practice due to hardware features such as SIMD instructions.

#text(blue)[#lorem(50)]

The FFT can be used to map a Polynomial from it's coefficient representation to
it's value representation.

== Coefficient to Value Representation of a Polynomial
#text(blue)[#lorem(100)]

== Bit Reversal in Signal Processing
#text(blue)[#lorem(100)]

= Applications and Limitations

Since the DFT is used to decompose a signal into it's constituent frequencies,
FFTs are useful in any application that requires frequency analysis. It's used
heavily in situations where the input signal is noisy, as by decomposing the
signal into the frequencies that make it up, it's possible to filter out those
that are irrelevant to the application.

For example, in speech detection a common preprocessing step is computing the
mel spectrogram of the input. This is done by taking a Short Time Fourier
Transform (STFT) of the input, which is a sliding window DFT where the center of
each window(or "sample") is equally distanced apart, these samples may or may
not overlap, and the exact number of samples is specified ahead of time(usually
2048). The output of this operation provides a spectrogram, which represents the
change in frequency content of the input over time.

The Mel Filterbank(a set of triangular filters spaced evenly on the mel scale)
are then created and applied to the spectrogram via einstein summation, this in
effect warps the frequency axis of the spectrogram to the mel scale, which is a
scale that more closely represents the way humans perceive sound. These
filterbanks are generally cached and then used for all future inputs.

This is used in most speech-based models as a preprocessing step, as it allows
the model to focus on the relevant frequencies of the input, and ignore those
that are irrelevant.

This is just one example of it's use in filtering. It's used in image
compression

== Limitations

The FFT is a discrete transform, and its inputs are often continuous signals
captured at fixed sample rates. The #text(blue)[#lorem(50)]

=== aliasing

In order to understand aliasing, let us first consider the Nyquist-Shannon
sampling theorem. If we sample a signal $X(t)$that is bandlimited, that is to
say, there is a frequency $f_("max")$ such that the Fourier transform of $X(t)$ is
zero for all $f>f_("max")$, then in order to perfectly reconstruct $X(t)$ from
it's samples, we must sample at a rate of at least $2 f_("max")$.

The folding frequency (or Nyquist frequency) is half the sampling frequency. $ f_("Nyquist")=1/2 f_"samples" $.
If there are no frequencies above this threshold, then the signal can be
perfectly reconstructed from it's samples.

If the the input signal contains frequencies above the Nyquist frequency, these
higher frequencies will be folded back into the lower frequencies, and are thus
indistinguishable from them. This is known as aliasing.

=== Picket-fence effect

Given a signal of length $N$, he ideal sampling frequency is $"desired number of points"*1/N$ where $1/N$ is
the fundamental frequency(the first/lowest frequency of a signal). Frequencies
that are integer multiples of the fundamental frequency are known as harmonics.
These harmonics are often referred to as "bins" in the context of the FFT, as
they act as a set of $N$ filters that capture the energy of the input signal at
each harmonic@Cerna_Harvey. If all the frequencies in the input are harmonics,
the output of the FFT will correctly identify them. However, if the input signal
contains a frequency that falls between two harmonics, it's energy will be
primariliy spread across the two harmonics, but will also affect the magnitudes
of the other harmonics. This is known as the picket-fence effect.

The name derives from the fact that some parts of the Sinusoid (of the
offcentered frequency) will be captured correctly at the bin, but the parts
falling between those bins will be occluded, as if viewed through a picket
fence.

=== Leakage

#text(blue)[#lorem(100)]
= Modern Implementations

== Planner

= Conclusion

