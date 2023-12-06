#import "template.typ": *
#show: ieee.with(
  title: "Fast Fourier Transforms",
  abstract: [
    In this paper, we delve into the realm of Fast Fourier Transforms (FFTs), a
    family of algorithms employed for computing the Discrete Fourier Transform
    (DFT). Recognizing the impracticality of direct DFT computation due to its $O(N^2)$ time complexity, we explore Cooley-Tukey radix-2 FFT extend our disccusion to other radix and non-radix based FFT algorithms. As each of the algorithms have the same $O(n log n)$ complexity, we discuss their distinguishing factors and when they are prefered. We will also discuss the limitations of FFTs related to it's use in mapping discrete data from the time to frequency domain, and how to mitigate them. We explore some examples of how FFTs are used, and how modern libraries go about selecting the best algorithm for a given context. Finally, we conclude with a discussion of the significance and impact of FFTs.
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
    "Radix-2",
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
DFT and Fourier Transforms in general. Also, given the intended audience for
this paper have a background in computer science, where signal processing is
somewhat an orthogonal topic, we will define any definitions, concepts, or
definitions that are related to signal processing as they are introduced.

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

//=== The Nth Root of Unity <n-roots>
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

// === Issues with direct computation of the DFT
The DFT is impractical to compute directly as it requires $4N^2$ floating point
operations. Though the computations of many of these operations are redundant,
used when calculating the values of multiple entries. This computational reuse
are what Fast Fourier Transforms exploit.

= Cooley-Tukey FFT

The Cooley-Tukey FFT was the "first" FFT algorithm, and was published in 1965 by
James Cooley and John Tukey#footnote[It was arguably "rediscoverd" as the same algorithm seems to have been first created by gauss in 1805, but this was only discovered after publication@heideman1985gauss]. It is a divide and conquer algorithm that makes use
of the symetries of the DFT to reduce the number of operations required from $4N^2$ to $2N log N$.
If $N$ in @DFT is a power of 2, and thus can be factored into $N=N_1 N_2$, we
can break $k,j$ into $k=k_1+k_2 N_1$ and $n=n_1 N_2 + j_2 $, and rewrite it as
$ A[k_1 + k_2 N_1] =\ sum_(n_2=0)^(N_2-1) W_(N_2)^(n_2 k_2) ( W_(N)^(n_2 k_1) sum_(n_1=0)^(N_1-1) a[n_1 N_2 + n_2] W_(N_1)^(n_1 k_1) ) $ <cooley-tukey>

This computes $N_2$ DFTs of length $N_1$, multiplies the result by $W_(N_2)^(n_2 k_2)$ and $W_(N)^(n_2 k_1)$,
and then computes a final DFT of length $N_2$ on the result. The algorithm can
be implemented iteratively or recursively. In a recursive implementation, the
base case is when $N=1$, which is just the identity
function.@frigoDesignImplementationFFTW32005, and the recurrence relation is $T(N)=2T(N/2) +Theta(N)$ <recurrence>.
Using the Master Theorem, since $c=log_b a=1$, $k=0$ and thus $f(n)=Theta(N)=Theta(n^c log^0 n)$,
it's time complexity is $Theta(N log N)$.

The three roots of unity $W_(N)^(n_2 k_1)$,$W_(N_2)^(n_2 k_2)$, and $W_(N_1)^(n_1 k_1)$ are
collectively known as the "twiddle factors". The reason $W_(N)^(n_2 k_1)$ is
used is to account for offsets in the time(or input) domain due to the
separation into smaller DFTs.

If $N_1$ or $N_2$ are bounded, they are often referred to as the "radix". In the
original Cooley-Tukey FFT, $N_1=2$ and $N_2=N/2$, and thus the radix is 2.
Though, other radices are possible, and are often used in practice. Generally,
the radix is chosen to be a power of 2, as is the case for the radix-4 and
radix-8 FFTs. These work by modifying the indices used by the "Decimation in
Time" algorithm, and modifies the twiddle factors to account for the new
indices. Each Radix-2#super[p] algorithm have $Theta(n log n)$ time complexity,
though they differ in the number of real and complex multiplications@bouguezelImprovedRadix4Radix82004. Radix-4
seems to be the commonly used radix-2#super[p] algorithm in FFT libraries such
as FFTW and RustFFT.

// In
// modern FFTs, the radix is often 4, 8, or 16. While these technically result in a
// higher number of operations (though still $O(N log N)$), they are often faster
// in practice due to hardware features such as SIMD instructions.

// In signal processing, decimation is a reduction in the sample rate. In the context of the FFT, decimation in time is a method of reorganizing the input signal rather than reducing its sample rate as in traditional signal processing. The process involves splitting the input sequence into two subsets containing the even and odd indexed samples. This division doesn't discard any data but reorders it for efficient FFT computation.

Decimation in Time refers to the fact that the input signal is decimated in the
time domain. For context, decimation is a reduction in the sample rate of a
signal. Normally, this would be cause a loss of information, but in the FFT it's
used to take a divide and conquer approach. In the radix-2 DIT FFT, the input
signal is broken into two smaller signals, each with half the number of samples
and half the sample rate. Since the samples that compose the input signal are
spaced according to the sample rate, and their order is preserved, the smaller
signals are composed of the even and odd samples of the input signal,
respectively. Because of this division, the input signal should be a power of 2.
For signals not meeting this criterion, padding can be used to extend the signal
to the nearest power of 2. Zero padding is typically used, though other padding
functions can be used as well. Zero padding doesn't alter the signal's frequency
resolution, but it does improve the estimations of the amplitude of its
frequencies.

//TODO: need a paragraph on DIF, then IFFT
There is also "Decimation in Frequency", which divides the input signal into two
halves based on the frequency domain. This works out to simply be the first and
second half of the input signal.

Since the FFT is just a fast way to compute the DFT, it has an inverse. The
algorithm for the inverse FFT is the same as the forward FFT, except the sign of
the exponent in the twiddle factors is reversed, and the final result is
normalized by $1/N$.

The length of the input should ideally be a power of 2. For signals not meeting
this criterion, zero padding can be used to extend the signal to the nearest
power of 2. This approach doesn't alter the signal's frequency content but
ensures compatibility with the FFT algorithm, a trade-off that's generally
worthwhile given the FFT's time complexity@aamirCooleyTukeyFFTMethod2005.

In the higher radix FFTs, the input signal is broken into subsets of lenth $N/r$ where $r$ is
the radix. In the same way that the input to the radix-2 should be a power of 2,
the input to the radix-2#super[p] FFT should be a power of 2#super[p]@amirfattahiCalculationComputationalComplexity2013.

Below is an implementation of the radix-2 DIT FFT in Python, followed by a
butterfly diagram that visualizes the operations performed by the algorithm.
Note this implementation is out of place, and thus requires $O(N)$ extra space.
This cost can be avoided by using an in place implementation, but would require
reordering the input array, as discussed in the next section. The out of place
implementation works in a top down, depth first fashion, first computing the FFT
of the even indices, followed by the odd indices, and then uses the result to
compute the final FFT.

```py
    def FFT(a: NDArray[complex]) -> NDArray[complex]:
        n: int = len(a) # n is a power of 2
        if n == 1:
            return a
        nth_root: complex = e**((2*pi*1j)/n)
        even: NDArray[complex] = FFT(a[::2])
        odd: NDArray[complex] = FFT(a[1::2])
        result= np.zeros(n, dtype=complex)
        for k in range(n//2):
            result[k] = (
                          even[k] +
                          (nth_root**k * odd[k])
                        )
            result[k+n//2] = (
                            even[k] -
                            (nth_root**k * odd[k])
                            )
        return result
```

#figure(
  image(".attachments/DIT-FFT-butterfly.png", width: 70%),
  caption: [
    Operations of an out of place 8-point FFT. #footnote[By Yangwenbo99 - Own work, CC BY-SA 4.0,\
      https://commons.wikimedia.org/w/index.php?curid=111271197]
  ],
)

== Bit Reversal in In Place FFT

// Let's examine the operations performed via the out-of-place radix-2 DFT via a
// butterfly diagram:

The out of place implementation works in a top down, depth first fashion,
whereas computing the FFT in place works in a bottom up, breadth first
fashion. It's worth noting that the original Cooley-Tukey FFT was in-place. In
order to ensure the operations are performed in the correct order, the input
array must be reordered. This is done by ordering the indices of the input array
by their bit-reversed representation. The butterfly diagram is for the FFT of an
8 element array. all Intermediate results are stored in the array for the
results, and the computations are completed for each stage prior to moving on to
the next one.

#figure(image(
  ".attachments/Example-of-an-8-point-FFT-butterfly-scheme_W640.jpg",
  //width: 80%,
), caption: [
  Operations of an in place 8-point FFT. @XtnesaLX4Configurable2013
])
//TODO: add a paragraph about DIF

= Other FFT Algorithms

So far we've only discussed the original Cooley-Tukey FFT, which is radix-2
algorithm, and briefly mentioned radix-2#super[p] algorithms, which are
generalizations of the radix-2 FFT to higher powers of 2. There are many other
FFT algorithms. each of these algorithms share the $O(n log n)$ time complexity
of the Cooley-Tukey FFT, but are suited to different input sizes and lengths.
We'll briefly discuss some radix based FFTs that aren't radix-2#super[p], and then discuss some of the non-radix based FFTs. This is not an exhaustive list, 
unfortunately, as there are many other FFT algorithms that we won't be able to cover. 

//#text(blue)[#lorem(50)]

== Split Radix FFT
Radix-4 has fewer operations than the radix-2, but places additional constraints
on the input size since not all factors of 2 are factors of 4. In each of the
radix-2#super[p] algorithms, the work is divided evenly between the two or more
subproblems. Split radix FFTs are a sort of hybrid between the radix-2 and
radix-4 FFTs. The input is split into 3 subsets of length $N/2$, $N/4$, and $N/4$,
and the work is divided unevenly between them. This uneven distribution of work
results in fewer arithmetic operations (both multiplications and additions), and
makes it well suited for large inputs@johnsonModifiedSplitRadixFFT2007a.

== Radix-3 FFT
The radix-3 FFT is a generalization of the radix-2 FFT that works on inputs that
are powers of 3@duboisNewAlgorithmRadix31978. It's efficient for inputs that are powers of 3, and it's worth
mentioning as it demonstrates that the radix based FFTs are not limited to
powers of 2, and along with the existence of Split Radix FFTs, help lay the
foundation of how modern FFT libraries work.

== Good-Thomas FFT
Also known as the Prime Factor FFT, the Good-Thomas FFT is a DFT algorithm that
works on inputs whose length $N$ can be factored into relatively prime values $N_1 N_2$. It can be recursively applied to the $N_1$ and $N_2$ subproblems, though, like the split radix FFT, other FFT algorithms can be used for the subproblems@pavanfft. Unlike the Radix based FFTs, It doesn't rely on multiplication of values by the $N$th roots of unity at every stage, and instead rearranges the input to be a $N_1 times N_2$ matrix, and then computes the FFT along the rows and columns of the matrix. 

== Bluestein's FFT
Bluestein's FFT is an algorithm for performing a chirp-z(CZT) transform, which is a generalization of the DFT. It expresses the CZT as a convolution, and can be used to perform more than just DFT transforms@amannahcomparative. It also has the advantage of working for arbitrary length inputs, including prime lengths. It calculates the DFT by using Z-transforms@pariyal2016comparison. 
//$ A(k)=W^(-1/2)k^2() $

== Discrete Cosine Transform (DCT)
Whereas the BlueStein FFT is a generalization of the DFT, the DCT can be thought of as a generalization of the FFT. It isn't a DFT transform, as it doesn't map from the time domain to the frequency domain. Instead it maps from the spatial to frequency domains@gupta2012analysis. It has an interesting property though, which is the input and output of a DCT are real. Because of this, it's widely used in lossy compression algorithms such as JPEG, MP3, as well as those used by video codecs. 

There are multiple variants of the DCT, the most common being the DCT-II, which is the same as the FFT, except in place of the roots of unity it uses the cosine function. DCT-III is the inverse of DCT-II.

= Applications

Since the DFT is used to decompose a signal into it's constituent frequencies,
FFTs are useful in any application that requires frequency analysis. It's used
heavily in situations where the input signal is noisy, as by decomposing the
signal into the frequencies that make it up, it's possible to filter out those
that are irrelevant to the application@heckbert1995fourier.

For example, in speech detection a common preprocessing step is computing the
mel spectrogram of the input@luSpeechRecognitionUsing2020. This is done by taking a Short Time Fourier
Transform (STFT) of the input, which is a sliding window DFT where the center of
each window(or "sample") is equally distanced apart, these samples may or may
not overlap, and the exact number of samples is specified ahead of time(usually
2048). The output of this operation provides a spectrogram, which represents the
change in frequency content of the input over time@grochenigFoundationsTimefrequencyAnalysis2001.

The Mel Filterbank(a set of triangular filters spaced evenly on the mel scale)
are then created and applied to the spectrogram via einstein summation, this in
effect warps the frequency axis of the spectrogram to the mel scale, which is a
scale that more closely represents the way humans perceive sound. These
filterbanks are generally cached and then used for all future inputs

This is used in most speech-based models as a preprocessing step, as it allows
the model to focus on the relevant frequencies of the input, and ignore those
that are irrelevant.

This is just one example of it's use in filtering. It's used in image
compression; the jpeg format uses DCTs for their compression algorithm. Much the
same way in image processing, it's useful for performing operations such as
gaussian blur, and underlies many filter and denoising functions. It's use in
science is near universal. The original problem which led to the publication of
the 1965 Cooley-Tukey paper was so that seismographic data could be used to
detect the size and distance of underground bomb test during the height of the
cold war@anscombeQuietContributorCivic2003.

Due to a certain problem symmetry that eludes the authors understanding, it can
also be used to convert a polynomial from it's coefficient representation to
it's it's value representation where each index is the evaluation of the
polynomial at the index value. Polynomial multiplication using the coefficient representation is $O(N^2)$, but only $O(N)$ using the value representation. The FFT(and it's inverse) can be used to convert between these two representations in $O(N log N)$ time, and thus can be used to multiply polynomials in $O(N log N)$ time.

= Limitations

// The most obvious limitation of (most) FFTs is the requirement on the input size. However either via padding or simply foresight, this can be mitigated. It's also worth noting that real valued inputs need to be converted to complex numbers, though in many cases the DCT can be used instead. 

There are some limitations of the algorithm related to it's use in signal processing. The FFT is a discrete transform, and its inputs are often continuous signals
captured at fixed sample rates. The Limitations of the FFT are thus related to
the sampling of the input signal.

== aliasing

In order to understand aliasing, let us first consider the Nyquist-Shannon
sampling theorem. If we sample a signal $X(t)$that is bandlimited, that is to
say, there is a frequency $f_("max")$ such that the Fourier transform of $X(t)$ is
zero for all $f>f_("max")$, then in order to perfectly reconstruct $X(t)$ from
it's samples, we must sample at a rate of at least $2 f_("max")$@Cerna_Harvey.

The folding frequency (or Nyquist frequency) is half the sampling frequency. $ f_("Nyquist")=1/2 f_"samples" $.
If there are no frequencies above this threshold, then the signal can be
perfectly reconstructed from it's samples.

If the the input signal contains frequencies above the Nyquist frequency, these
higher frequencies will be folded back into the lower frequencies, and are thus
indistinguishable from them@girgisQuantitativeStudyPitfalls1980. This is known as aliasing.

== Picket-fence effect

Given a signal of length $N$, the ideal sampling frequency is $"desired number of points"*1/N$ where $1/N$ is
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
fence@Cerna_Harvey.

== Spectral Leakage

The FFT assumes that the input signal is periodic, and that the samples are
taken over a single period. If the input signal is not periodic within the
sample window this will result discontinuities at the window boundaries. As a
result, the energy of each frequency will be spread across the bins, resulting
in a smearing effect known as spectral leakage.

The leakage effect can be reduced by applying a window function to the input.
Window functions are (typically smooth, bell-curved shaped) functions that are
zero outside of a certain range@Cerna_Harvey. These are applied to the input via elementwise
multiplication, and the FFT is then applied to the result. This tapering of the
input signal reduces the discontinuities at the window boundaries, and thus
reduces the spectral leakage effect.

This is a trade-off between frequency resolution and spectral leakage. When a
window function is used, the signal's edges are smoothed, which reduces leakage
but at the expense of blurring the frequency components. This blurring effect
can make it difficult to distinguish between closely spaced frequencies, leading
to a loss of resolution. This trade-off can be minimized by selecting an
appropriate window function.

//Therefore, selecting an appropriate window function depends on the specific requirements of the analysis, balancing the need to minimize leakage with the requirement for precise frequency resolution.

= Modern Implementations

As FFTs are often to a certain degree decomposable, and what is faster often depends both attributes of the input and on the availability of hardware features, modern FFT libraries tend to take a compositional approach. Instead, execution tends to happen in two phases, a planning phase and an execution phase. The planning phase is where the input and the environment are analyzed, and an algorithm is either selected or generated. The planning phase is often cached, either in memory or on disk, and is reused for all future inputs. The execution phase is supplied with the input and the plan, and performs the FFT.

In FFTW, the planner has multiple modes, ranging from "patient" to "estimate"@frigoDesignImplementationFFTW32005. In Patient mode, the planner will try all fragments of optimized straight-line code (called codelets), and measure their performance using a dynamic programming approach. In estimate mode, the planner will minimize a cost function and avoid performing any measurements, and thus is much faster than the patient mode. As it is a dynamic programming algorithm, it will often solve subproblems multiple times. The planner can only find the approximate optimal plan.

The codelets are generated by a specialized compiler that creates optimized codelets based on an abstract description of the special cases of the DFT. Most users won't need to do this, as the library comes with 150 pregenerated codelets(though this number may not be accurate as it is from the 2005 paper). These codelets compose the space of possible plans the planner can generate.


This compositional approach also means that libraries are portable, and can be used on a variety of architectures. Prior to the compositional approach, FFTs were often hand tuned for specific architectures and hardware.

Other FFT libraries generally work in a similar, albeit often simpler, fashion. RustFFT, for example, composes the FFTs from structures called "butterflies", which are the basic building blocks of the FFT. It, like FFTW, has different implementations based off the availablity of hardware instructions, such as AVX and Neon@RustfftRust. 

= Conclusion

FFTs are arguably one of the most important algorithms in use today. In the preface of 'The Fast Fourier transform' the author states that "The Fourier transform has long been a principle analytical tool in such diverse fields as linar systems, optics, probability theory, quantum mechanics, antennas, and signal analysis. A similar statement is not true for the discrete Fourier transform."@brighamFastFourierTransform1974 It was just too expensive to compute directly. The FFT enabled the use of the DFT in a way that was previously impossible. 

Since cooley-tukey published their paper in 1965, the set of FFT algorithms has expanded from the radix-2 to include many other algorithms, each generally employing a similar divide and conquer approach. Most of these algorithms (all of the ones we covered) achieve $O(n log n)$ time complexity, but differ in their operation counts and suitability for different input sizes. 

They aren't without their limitations. They inherent these limitations from the DFT, and thus require a little domain knowledge to use effectively. These limitations can be mitigated, and what they offer is often worth the cost acquiring the prerequisite knowledge.

FFTs enable our societies use of digital media, without which our bandwidth would struggle or fail to meet the demands of modern society. These algorithms enable the pursuit of almost every science, arguably every science which requires at least some analysis of time series data. They also underly the preprocessing steps of many machine learning models, and are used in many of the models themselves. Without the FFT, our world would be a different, lesser place.