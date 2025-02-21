#' Show channel signals with diagnostic plots
#' @description The diagnostic plots include 'Welch Periodogram'
#' (\code{\link{pwelch}}) and histogram (\code{\link[graphics]{hist}})
#' @param s1 the main signal to draw
#' @param s2 the comparing signal to draw; usually \code{s1} after some filters;
#' must be in the same sampling rate with \code{s1}; can be \code{NULL}
#' @param sc decimated \code{s1} to show if \code{srate} is too high; will
#' be automatically generated if \code{NULL}
#' @param srate sampling rate
#' @param name name of \code{s1}, or a vector of two names of \code{s1} and
#' \code{s2} if \code{s2} is provided
#' @param try_compress whether try to compress (decimate) \code{s1} if
#' \code{srate} is too high for performance concerns
#' @param max_freq the maximum frequency to display in 'Welch Periodograms'
#' @param plim the y-axis limit to draw in 'Welch Periodograms'
#' @param window,noverlap see \code{\link{pwelch}}
#' @param cex,lwd,mar,mai,... graphical parameters; see \code{\link[graphics]{par}}
#' @param nclass number of classes to show in histogram
#' (\code{\link[graphics]{hist}})
#' @param main the title of the signal plot
#' @param col colors of \code{s1} and \code{s2}
#' @param which \code{NULL} or integer from 1 to 4; if \code{NULL}, all plots
#' will be displayed; otherwise only the subplot will be displayed
#' @param start_time the starting time of channel (will only be used to draw
#' signals)
#' @param boundary a red boundary to show in channel plot; default is
#' to be automatically determined by \code{std}
#' @param std the standard deviation of the channel signals used to determine
#' \code{boundary}; default is plus-minus 3 standard deviation
#' @return A list of boundary and y-axis limit used to draw the channel
#' @examples
#' library(ravetools)
#'
#' # Generate 20 second data at 2000 Hz
#' time <- seq(0, 20, by = 1 / 2000)
#' signal <- sin( 120 * pi * time) +
#'   sin(time * 20*pi) +
#'   exp(-time^2) *
#'   cos(time * 10*pi) +
#'   rnorm(length(time))
#'
#' signal2 <- notch_filter(signal, 2000)
#'
#' diagnose_channel(signal, signal2, srate = 2000,
#'                  name = c("Raw", "Filtered"), cex = 1)
#'
#' @export
diagnose_channel <- function(
  s1, s2 = NULL, sc = NULL, srate, name = '', try_compress = TRUE,
  max_freq = 300, window = ceiling(srate * 2), noverlap = window / 2, std = 3,
  cex = 1.5, lwd = 0.5, plim = NULL, nclass = 100,
  main = 'Channel Inspection', col = c('black', 'red'),
  which = NULL, start_time = 0, boundary = NULL,
  mar = c(5.2, 5.1, 4.1, 2.1), mai = c(0.6, 0.54, 0.4, 0.1),
  ...){

  # is sc not specified, and srate is too high, compress s1
  if(try_compress && (is.null(sc) || (srate > 200 && length(s1) / srate > 300))){
    sratec <- 100
    sc <- s1[round(seq(1, length(s1), by = srate/sratec))]
  }else{
    sc %?<-% s1
    sratec <- srate / length(s1) * length(sc)
  }
  max_freq <- min(max_freq, floor(srate/ 2))
  xlim <- c(0, max_freq)

  # Calculate boundary to draw
  if(is.null(boundary)){
    boundary <- std* stats::sd(s1)
  }
  ylim <- max(abs(s1), boundary)

  # Grid layout

  par_opt <- graphics::par(c('mai', "mar"))
  on.exit({graphics::par(par_opt)}, add = TRUE)
  graphics::par(mar = mar, mai = mai)

  if(length(which) == 0){
    # grid::grid.newpage()
    lay <- rbind(c(1,1,1), c(2,3,4))
    graphics::layout(mat = lay)
  }

  # First plot: plot sc directly with col[1]
  if(length(which) == 0 || 1 %in% which){
    graphics::plot(start_time + (seq_along(sc) / sratec), sc, xlab = 'Time (seconds)', ylab = 'Voltage',
                   main = main, lwd = lwd,
                   type = 'l', ylim = c(-ylim-1, ylim+1), yaxt="n", col = col[1],
                   cex.axis = cex * 0.7, cex.lab = cex *0.8, cex.main = cex, cex.sub = cex, ...)
    graphics::abline(h = c(-1,1) * boundary, col = 'red')
    ticks<-c(-ylim, -boundary,0,boundary, ylim)
    graphics::axis(2,at=ticks,labels=round(ticks), las = 1,
                   cex.axis = cex*0.7, cex.lab = cex *0.8, cex.main = cex, cex.sub = cex)
  }

  # plot 2, 3 too slow, need to be faster - pwelch periodogram
  if(length(which) == 0 || 2 %in% which){
    if(!is.null(s2)){
      pwelch(s2, fs = srate, window = window,
             noverlap = noverlap, plot = 1, col = col[2], cex = cex, ylim = plim,
             log = 'y', xlim = xlim)
      pwelch(s1, fs = srate, window = window, noverlap = noverlap, cex = cex, ylim = plim,
             plot = 2, col = col[1], log = 'y', xlim = xlim)
      graphics::legend('topright', name, col = col, lty = 1, cex = cex * 0.8, bty = "n")
    }else{
      pwelch(s1, fs = srate, window = window,
             noverlap = noverlap, plot = 1, col = col[1], cex = cex, ylim = plim,
             log = 'y', xlim = xlim)
    }
  }


  if(length(which) == 0 || 3 %in% which){
    log_xlim <- log10(sapply(xlim, max, 1))
    if(!is.null(s2)){
      pwelch(s2, fs = srate, window = window,
             noverlap = noverlap, plot = 1, col = col[2], cex = cex, ylim = plim,
             log = 'xy', xlim = log_xlim)
      pwelch(s1, fs = srate, window = window, noverlap = noverlap, cex = cex, ylim = plim,
             plot = 2, col = col[1], log = 'xy', xlim = log_xlim)
      graphics::legend('topright', name, col = col, lty = 1, cex = cex * 0.8, bty = "n")
    }else{
      pwelch(s1, fs = srate, window = window,
             noverlap = noverlap, plot = 1, col = col[1], cex = cex, ylim = plim,
             log = 'xy', xlim = log_xlim)
    }
  }


  if(length(which) == 0 || 4 %in% which){
    # Plot 4:
    graphics::hist(s1, nclass = nclass,
                   xlab = 'Signal Voltage Histogram', main = paste0('Histogram ', name[[1]]),
                   cex.axis = cex * 0.7, cex.lab = cex*0.8, cex.main = cex, cex.sub = cex)
  }

  return(invisible(list(
    ylim = ylim,
    boundary = boundary
  )))
}
