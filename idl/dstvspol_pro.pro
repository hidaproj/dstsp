; pro_obs.pro
;  2010.09.11	T.A.
;回転波長版Hzのヘッダー取り込み

@DSTPOL_widget

loadct,0
tmp=timeinit()
MessageBox,'Are you ready Prosilica, rotating waveplate, HA & ZD ?'
MessageBox,'If you use, are you ready Auto-Rotate Pol. ?'

DSTPOL_widget

END
