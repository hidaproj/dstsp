
## pro `slofo`

- NAME: SLOFO (= SLOw FOurier)
- PURPOSE: does power spectra the hard way, good for unevenly sampled data

```
pro slofo,seconds,timeseries,power,freq,freqrange,deltaf, $
  noverbose = noverbose, nonorm = nonorm
```

INPUTS:
- seconds: data times in seconds
- timeseries: the time-series data 
- freqrange: optional frequency range ([f_min,f_max]) in Hz 
- deltaf: optional spacing of estimates in frequency in Hz 
- /noverbose: defeats the messages
- /nonorm: defeats normalization to the mean (i.e. leaves dimensions in)

OUTPUTS:
- power = power estimates (/Hz)
- freq = at what frequencies estimated (Hz)

```
secs = seconds - min(seconds)
rtvar = stdev(timeseries, mseries)
tseries = timeseries - mseries 
tseries = tseries / mseries
if keyword_set(nonorm) eq 1 then tseries = tseries * mseries
```
- `secs` starts from `0` sec.
- `rtvar` is the stddev of data series, and `mseries` is the mean of data series.
- `tseries` is data sereis minus its mean (and further normalized by its mean if `nonorm` is not set).

> usage of `stdev` : `array_std = stdev(array, [array_mean])`.  
> 
> this function also compute the mean optionally

```
trange = max(secs) 
meant = trange*1./n_elements(secs)
fnought  = 1./trange
fnyquist = .5/meant 
if n_elements(freqrange) eq 0 then freqrange = [fnought,fnyquist]
if n_elements(deltaf) eq 0 then deltaf = fnought
```

- `freqrange` : frequency range ([f_min,f_max]) in Hz 
- `deltaf` : spacing of estimates in frequency in Hz

> shouldn't `deltaf` be `2*fnyquist` ?

```
n_points = (freqrange(1) - freqrange(0))/deltaf
power = fltarr(n_points-2) & freq = fltarr(n_points-2)
```

from now on, not clear. let's accept this function returns the power `pw` (/HZ) and the corresponding frequency `freq` (HZ).

## function `fun`

```
FUNCTION fun,X,P

ymod = p[0] + p[1] *sin(p[2]*x+p[3])

return,ymod
END
```

4 parameters, returning a biased amplified sine curve

## function `ta_sinfit_mpfit`

