#ifndef RAVEUTILS_FFTW_WRAPPER_H
#define RAVEUTILS_FFTW_WRAPPER_H

#include <Rcpp.h>

SEXP fftw_r2c(SEXP data, int HermConj, int fftwplanopt, SEXP ret, bool inplace);

SEXP mvfft_r2c(SEXP data, int HermConj, int fftwplanopt, SEXP ret, bool inplace);

SEXP fftw_c2c(SEXP data, int inverse, SEXP ret, bool inplace);

SEXP fftw_c2r(SEXP data, int HermConj, SEXP ret, bool inplace);

SEXP conjugate(SEXP data);

#endif // RAVEUTILS_FFTW_WRAPPER_H

