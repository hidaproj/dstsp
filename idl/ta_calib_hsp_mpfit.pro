;+
; NAME       : ta_calib_hsp_mpfit.pro (function)
; PURPOSE :
; 	return parameters of DST model fitted observational data
;	by using mpfit 
; CALLING SEQUENCE :
;        res=
; INPUTS :
; OUTPUT :
; OPTIONAL INPUT PARAMETERS : 
; KEYWORD PARAMETERS :
; MODIFICATION HISTORY :
;      ver=0   T.A. '16/10/26
;      ver=1   T.A. '17/01/10   ver keyword, angle of calibration unit
;      ver=3   T.A. '17/01/16   use MMSP2 data in 20170103, ir fixed
;*******************************************************************
@/home/anan/lib/DSTPOL/polarimeterlib_v2.pro
;@~/study/program/idl/program_anan/DSTPOL/polarimeterlib_v2.pro
;==========================================================;
FUNCTION fit_fun,X,P,vertmp=vertmp,hdstmp=hdstmp,weighttmp=weighttmp,mms=mms
common com,weight,ver,hds

if keyword_set(vertmp) then ver=vertmp
if keyword_set(hdstmp) then hds=hdstmp
if keyword_set(weighttmp) then weight=weighttmp
;ro_N	= p[0]	,tau_N= p[1]	,ro_C	= p[2]	,tau_C= p[3]
nd	= (size(x,/dim))[0]
ha 	= x[*,0]
zd0 	= x[*,1]
imgrot  = x[*,2]
az	= x[*,3]
incli	= x[*,4]
key	= x[*,5]
mms=fltarr(4,4,nd)
ymod=fltarr(nd)
for i=0,nd-1 do begin
	case key[i] of
		0:begin
			stk0=transpose([1.,0.,0.,0.])
			istks=1
		end
		1:begin
			stk0=transpose([1.,0.,0.,0.])
			istks=2
		end
		2:begin
			stk0=transpose([1.,0.,0.,0.])
			istks=3
		end
		3:begin
			stk0=transpose([1.,1.,0.,0.])
			istks=1
		end
		4:begin
			stk0=transpose([1.,1.,0.,0.])
			istks=2
		end
		5:begin
			stk0=transpose([1.,1.,0.,0.])
			istks=3
		end
		6:begin
			stk0=transpose([1.,-1.,0.,0.])
			istks=1
		end
		7:begin
			stk0=transpose([1.,-1.,0.,0.])
			istks=2
		end
		8:begin
			stk0=transpose([1.,-1.,0.,0.])
			istks=3
		end
		9:begin
			stk0=transpose([1.,0.,1.,0.])
			istks=1
		end
		10:begin
			stk0=transpose([1.,0.,1.,0.])
			istks=2
		end
		11:begin
			stk0=transpose([1.,0.,1.,0.])
			istks=3
		end
		12:begin
			stk0=transpose([1.,0.,-1.,0.])
			istks=1
		end
		13:begin
			stk0=transpose([1.,0.,-1.,0.])
			istks=2
		end
		14:begin
			stk0=transpose([1.,0.,-1.,0.])
			istks=3
		end
	endcase
	case ver of
		0:begin
			mm=mm_dst(0,p,imgrot=imgrot[i],/newton,     $
		  		zd=zd0[i],ha=ha[i],az=az[i],incli=incli[i],/hsp,version=2)
		end
		1:begin
			mm=mm_dst(0,p,imgrot=imgrot[i],/newton,     $
		  		zd=zd0[i],ha=ha[i],az=az[i],incli=incli[i],/hsp,version=2)
		end
		else: begin
        		mm=mm_dst(hds[i],p,imgrot=imgrot[i],/newton,     $
                		zd=zd0[i],ha=ha[i],az=az[i],incli=incli[i],/hsp,version=ver)
		end
	endcase
	case ver of
        	0:stk1=mm ## stk0
        	1:stk1=mm ## muellermatrix_rot(p[45]) ## stk0
        	3:stk1=mm ## muellermatrix_rot(p[45]) ## stk0
		else:print,'no version',ver
	endcase
	ymod[i]=stk1[istks]/stk1[0] 
	mms[*,*,i]=mm
endfor
ymod[where(key eq 0 or key eq 1 or key eq 2)]=ymod[where(key eq 0 or key eq 1 or key eq 2)]*weight

return,ymod
END
;==========================================================;
function ta_calib_hsp_mpfit,stks,hd,par,fixed=fixed,draw=draw,  $
                            yfit_origin=yfit_origin,yfit_final=yfit_final,yy=yy,    $
                            imgrot=imgrot,azimuth=azimuth,      $
                            no_origin_plot=no_origin_plot,      $        ; 2016.11.30 TA
			    version=version
			;,funnum=funnum,telpos=telpos,perror=perror,$
			;click=click,draw=draw,error=error
; stks (# of time,3)
; hd   index
; p0   parameters of mm_dst, version 2
common com,weight,ver,hds



weight=10.

if not keyword_set(fixed) then fixed=fltarr(45)
if not keyword_set(no_origin_plot) then no_origin_plot=0
if not keyword_set(version) then ver=0 else ver=version
case ver of
	0:parinfo = replicate({value:0.D,fixed:0,  $
		limited:[0,0],limits:[0.D,0],step:0.d},45)
	1:parinfo = replicate({value:0.D,fixed:0,  $
		limited:[0,0],limits:[0.D,0],step:0.d},46)
	3:parinfo = replicate({value:0.D,fixed:0,  $
		limited:[0,0],limits:[0.D,0],step:0.d},46)
	else:print,'no version',ver
endcase
parinfo[*].value        = par*1d

parinfo[0].fixed	= fixed[0]   ; diattenuation of Newton mirror 
parinfo[1].fixed 	= fixed[1]   ; retardation of Newton mirror
parinfo[2].fixed 	= fixed[2]   ; diattenuation of Coude mirror
parinfo[3].fixed 	= fixed[3]   ; retardation of Coude mirror
parinfo[4].fixed 	= fixed[4]   ; stray light
parinfo[5].fixed 	= fixed[5]   ; retardance of entrance window
parinfo[6].fixed 	= fixed[6]   ; angle of the axis of entrance window
parinfo[7].fixed        = fixed[7]   ; retardance of exit window
parinfo[8].fixed        = fixed[8]   ; angle of the axis of exit window
parinfo[9].fixed        = fixed[9]   ; angle DST - MMSP2
parinfo[10].fixed       = fixed[10]  ; angle MMSP2 - Analyzer
parinfo[11].fixed       = fixed[11]  ; mm_ir[0,0], mm00
parinfo[12].fixed       = fixed[12]  ; mm_ir[1,0], mm01
parinfo[13].fixed       = fixed[13]  ; mm_ir[2,0], mm02
parinfo[14].fixed       = fixed[14]  ; mm_ir[3,0], mm03
parinfo[15].fixed       = fixed[15]  ; mm_ir[0,1], mm10
parinfo[16].fixed       = fixed[16]  ; mm_ir[1,1], mm11
parinfo[17].fixed       = fixed[17]  ; mm_ir[2,1], mm12
parinfo[18].fixed       = fixed[18]  ; mm_ir[3,1], mm13
parinfo[19].fixed       = fixed[19]  ; mm_ir[0,2], mm20
parinfo[20].fixed       = fixed[20]  ; mm_ir[1,2], mm21
parinfo[21].fixed       = fixed[21]  ; mm_ir[2,2], mm22
parinfo[22].fixed       = fixed[22]  ; mm_ir[3,2], mm23
parinfo[23].fixed       = fixed[23]  ; mm_ir[0,3], mm30
parinfo[24].fixed       = fixed[24]  ; mm_ir[1,3], mm31
parinfo[25].fixed       = fixed[25]  ; mm_ir[2,3], mm32
parinfo[26].fixed       = fixed[26]  ; mm_ir[3,3], mm33
parinfo[27].fixed       = fixed[27]  ; mm_45[0,0], mm00
parinfo[28].fixed       = fixed[28]  ; mm_45[1,0], mm01
parinfo[29].fixed       = fixed[29]  ; mm_45[2,0], mm02
parinfo[30].fixed       = fixed[30]  ; mm_45[3,0], mm03
parinfo[31].fixed       = fixed[31]  ; mm_45[0,1], mm10
parinfo[32].fixed       = fixed[32]  ; mm_45[1,1], mm11
parinfo[33].fixed       = fixed[33]  ; mm_45[2,1], mm12
parinfo[34].fixed       = fixed[34]  ; mm_45[3,1], mm13
parinfo[35].fixed       = fixed[35]  ; mm_45[0,2], mm20
parinfo[36].fixed       = fixed[36]  ; mm_45[1,2], mm21
parinfo[37].fixed       = fixed[37]  ; mm_45[2,2], mm22
parinfo[38].fixed       = fixed[38]  ; mm_45[3,2], mm23
parinfo[39].fixed       = fixed[39]  ; mm_45[0,3], mm30
parinfo[40].fixed       = fixed[40]  ; mm_45[1,3], mm31
parinfo[41].fixed       = fixed[41]  ; mm_45[2,3], mm32
parinfo[42].fixed       = fixed[42]  ; mm_45[3,3], mm33
parinfo[43].fixed       = fixed[43]  ; th1
parinfo[44].fixed       = fixed[44]  ; th2
parinfo[45].fixed       = fixed[45]  ; angle of calibration unit

parinfo[0].limited[*] = 1 & parinfo[0].limits[*] = [-1.D,1.D]
parinfo[2].limited[*] = 1 & parinfo[2].limits[*] = [-1.D,1.D]
parinfo[4].limited[*] = 1 & parinfo[4].limits[*] = [0.D,1.D]
for i=0,14 do begin
	parinfo[12+i].limited[*] = 1
	parinfo[12+i].limits[*] = [-par[11],par[11]]
	parinfo[28+i].limited[*] = 1
	parinfo[28+i].limits[*] = [-par[27],par[27]]
endfor

nd = n_elements(hd)
hd2angle,hd,ha,zd,r,p,incli
hds= [hd,hd,hd]
zd = [zd,zd,zd]
ha = [ha,ha,ha]
incli=[incli,incli,incli]
ir = [imgrot,imgrot,imgrot]
az = [azimuth,azimuth,azimuth]

key= fltarr(3*nd)


for kk=0,4 do begin
    case kk of
        0:pp=where(hd.polstate eq '')
        1:pp=where((hd.polstate eq '0') or (hd.polstate eq '180'))
        2:pp=where((hd.polstate eq '90') or (hd.polstate eq '270'))
        3:pp=where((hd.polstate eq '45') or (hd.polstate eq '225'))
        4:pp=where((hd.polstate eq '135') or (hd.polstate eq '315'))
     endcase
 print,pp
    key[pp]=3*kk+0 & key[pp+nd]=3*kk+1 & key[pp+2*nd]=3*kk+2 
endfor

yy = [stks[*,0],stks[*,1],stks[*,2]]
;yy1 = yy
;yy1[where(key eq 0 or key eq 1 or key eq 2)]=yy1[where(key eq 0 or key eq 1 or key eq 2)]*weight

pos=where(zd ne 0 and ha ne 0 and abs(yy) le 1,npos)
if npos ge 1 then begin
	zd=zd[pos]
	ha=ha[pos]
	incli=incli[pos]
	yy=yy[pos]
	key=key[pos]
	ir=ir[pos]
	az=az[pos]
endif

yyw=yy
yyw[where(key eq 0 or key eq 1 or key eq 2)]=yyw[where(key eq 0 or key eq 1 or key eq 2)]*weight

sy	=	.02
sy	=	.001
xx      = [[ha],[zd],[ir],[az],[incli],[key]]
yfit0w=fit_fun(xx,parinfo.value)

res = mpfitfun('fit_fun',xx,yyw,sy,parinfo.value,$
                   yfit=yfitw,errmsg=errmsg,STATUS=status,$
                   GTOL=1d-10,parinfo=parinfo,perror=perror)
;res=parinfo.value & yfitw=yfit0w & status='' & errmsg='' & perror=' '



yfit0=yfit0w
yfit0[where(key eq 0 or key eq 1 or key eq 2)]=yfit0[where(key eq 0 or key eq 1 or key eq 2)]/weight
yfit_origin=yfit0
yfit=yfitw
yfit[where(key eq 0 or key eq 1 or key eq 2)]=yfit[where(key eq 0 or key eq 1 or key eq 2)]/weight
yfit_final=yfit
print,status,'msg=',errmsg
print,perror

if keyword_set(draw) then begin
   chs=1.5
   window,0,xs=1000,ys=600
   set_line_color
   !p.multi=[0,5,3]
   
   for i=0,2 do begin
      if i eq 0 then title='(1,0,0,0)' else title=''
      pos=where(key eq 0+i)
      plot,xx[pos,0]*!radeg,yy[pos],psym=1,   $
         yr=[(min([yy[pos],yfit0[pos],yfit[pos]])-0.01)>(-1.),  $
             (max([yy[pos],yfit0[pos],yfit[pos]])+0.01)<(1.)], $
         ystyle=1, $ 
         charsize=chs,color=0,background=1,xtitle='HA (deg)',title=title
      if no_origin_plot eq 0 then oplot,xx[pos,0]*!radeg,yfit0[pos],line=2,color=0
      oplot,xx[pos,0]*!radeg,yfit[pos],color=3

      if i eq 0 then title='(1,1,0,0)' else title=''
      pos=where(key eq 1*3+i)
      plot,xx[pos,0]*!radeg,yy[pos],psym=1,yr=[-1,1],ystyle=1,   $
         charsize=chs,color=0,background=1,xtitle='HA (deg)',title=title
      if no_origin_plot eq 0 then oplot,xx[pos,0]*!radeg,yfit0[pos],line=2,color=0
      oplot,xx[pos,0]*!radeg,yfit[pos],color=3

      if i eq 0 then title='(1,-1,0,0)' else title=''
      pos=where(key eq 2*3+i)
      plot,xx[pos,0]*!radeg,yy[pos],psym=1,yr=[-1,1],ystyle=1,   $
         charsize=chs,color=0,background=1,xtitle='HA (deg)',title=title
      if no_origin_plot eq 0 then oplot,xx[pos,0]*!radeg,yfit0[pos],line=2,color=0
      oplot,xx[pos,0]*!radeg,yfit[pos],color=3

      if i eq 0 then title='(1,0,1,0)' else title=''
      pos=where(key eq 3*3+i)
      plot,xx[pos,0]*!radeg,yy[pos],psym=1,yr=[-1,1],ystyle=1,   $
         charsize=chs,color=0,background=1,xtitle='HA (deg)',title=title
      if no_origin_plot eq 0 then oplot,xx[pos,0]*!radeg,yfit0[pos],line=2,color=0
      oplot,xx[pos,0]*!radeg,yfit[pos],color=3

      if i eq 0 then title='(1,0,-1,0)' else title=''
      pos=where(key eq 4*3+i)
      plot,xx[pos,0]*!radeg,yy[pos],psym=1,yr=[-1,1],ystyle=1,   $
         charsize=chs,color=0,background=1,xtitle='HA (deg)',title=title 

      if no_origin_plot eq 0 then oplot,xx[pos,0]*!radeg,yfit0[pos],line=2,color=0
      oplot,xx[pos,0]*!radeg,yfit[pos],color=3
   endfor;i

;=============================
   chs=1.5
   window,1,xs=700,ys=700
   set_line_color
   !p.multi=[0,4,4]

   ; I=>I
   pos=where(key eq 0)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,nodata=1,  $ 
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
   ; Q=>I
   pos=where(key eq 0)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,nodata=1,  $ 
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
   ; U=>I
   pos=where(key eq 0)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,nodata=1,  $ 
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
   ; V=>I
   pos=where(key eq 0)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,nodata=1,  $ 
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'

   ; I=>Q
   yr=0.0001
   pos=where(key eq 0)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,yr=[-yr,yr]*20, $ 
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
   oplot,!x.crange,[yr,yr],color=0,line=0   
   oplot,!x.crange,-[yr,yr],color=0,line=0   

   ; Q=>Q
   yr=0.050
   pos=where(key eq 3)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,yr=[-yr,yr]*3, $ 
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
   pos=where(key eq 6)
   oplot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],color=0,psym=4
   oplot,!x.crange,[yr,yr],color=0,line=0   
   oplot,!x.crange,-[yr,yr],color=0,line=0   

   ; U=>Q
   yr=0.007
   pos=where(key eq 9)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,yr=[-yr,yr]*10, $ 
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
   pos=where(key eq 12)
   oplot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],color=0,psym=4
   oplot,!x.crange,[yr,yr],color=0,line=0   
   oplot,!x.crange,-[yr,yr],color=0,line=0   
 
   ; V=>Q
   pos=where(key eq 0)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,nodata=1,  $ 
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
   
   ; I=>U
   yr=0.0001
   pos=where(key eq 1)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,yr=[-yr,yr]*20., $ 
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
   oplot,!x.crange,[yr,yr],color=0,line=0   
   oplot,!x.crange,-[yr,yr],color=0,line=0   

   ; Q=>U
   yr=0.007
   pos=where(key eq 4)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,yr=[-yr,yr]*10, $ 
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
   pos=where(key eq 7)
   oplot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],color=0,psym=4
   oplot,!x.crange,[yr,yr],color=0,line=0   
   oplot,!x.crange,-[yr,yr],color=0,line=0   

   ; U=>U
   yr=0.05
   pos=where(key eq 10)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,yr=[-yr,yr]*3, $ 
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
   pos=where(key eq 13)
   oplot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],color=0,psym=4
   oplot,!x.crange,[yr,yr],color=0,line=0   
   oplot,!x.crange,-[yr,yr],color=0,line=0   

   ; V=>U
   pos=where(key eq 0)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,nodata=1,  $ 
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'

   ; I=>V
   yr=0.0001
   pos=where(key eq 2)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,yr=[-yr,yr]*20., $
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
   oplot,!x.crange,[yr,yr],color=0,line=0   
   oplot,!x.crange,-[yr,yr],color=0,line=0   

   ; Q=>V
   yr=0.007
   pos=where(key eq 5)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,yr=[-yr,yr]*10, $
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
   pos=where(key eq 8)
   oplot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],color=0,psym=4
   oplot,!x.crange,[yr,yr],color=0,line=0   
   oplot,!x.crange,-[yr,yr],color=0,line=0   

   ; U=>V
   yr=0.007
   pos=where(key eq 11)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      ystyle=1,yr=[-yr,yr]*10, $
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
   pos=where(key eq 14)
   oplot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],color=0,psym=4
   oplot,!x.crange,[yr,yr],color=0,line=0   
   oplot,!x.crange,-[yr,yr],color=0,line=0   
   
   ; V=>V
   pos=where(key eq 0)
   plot,xx[pos,0]*!radeg,yfit[pos]-yy[pos],psym=1,   $
      yr=[(min([yy[pos],yfit0[pos],yfit[pos]])-0.01)>(-1.),  $
          (max([yy[pos],yfit0[pos],yfit[pos]])+0.01)<(1.)], $
      ystyle=1,nodata=1,  $ 
      charsize=chs,color=0,background=1,xtitle='HA (deg)',ytitle='MDL - OBS'
endif
!p.multi=0
loadct,0

print,'rms',sqrt(mean((yy-yfit)^2))
print,res[0],res[1]*!radeg,res[2],res[3]*!radeg,res[4]
print,res[5],res[6],res[7],res[8]
print,'th_DST-MMSP2',res[9]*!radeg
print,'th_MMSP2-PBS',res[10]*!radeg
print,'MM_IR',res[11:26]
print,'MM_45',res[27:42]
print,'th_1,th_2',res[43:44]
if ver ne 0 then print,'th calibration unit (deg)',res[45]*!radeg

return,res
end
