@./polarimeterlib_v1.pro
pro update_cal_dstsp,date

;ffo='2013b'
;ffo='2014a'



ref_month2=['January','February','March','April','May','June',$
                'July','August','September','October','November','December']
year=strmid(date,0,4)
ck_mon=fix(strmid(date,4,2))
;if ck_mon gt 6 then ffo=year+'b' else ffo=year+'a'
mon2=ref_month2(ck_mon-1)
day=string(float(strmid(date,6,2)),format="(i0)")

org=read_file('/sp_pub/DSTSP_'+year+'.html',/str)
spawn,'\cp /sp_pub/DSTSP_'+year+'.html /sp_pub/DSTSP_'+year+'_backup.html'

print,mon2
ckmon='<caption><h3>'+mon2+'</h3></caption>'
ck1=where(org eq ckmon)
print,ck1
ck2=where(org(ck1:*) eq '<td align=center height=30 width=30 style="background: #aaffaa"><a href="./'+date+'/'+date+'.html">'+day+'</a></td>')

if ck2(0) eq -1 then begin

ck3=where(org(ck1:*) eq '<td align=center height=30 width=30>'+day+'</td>')
res=org
res(ck1+ck3)='<td align=center height=30 width=30 style="background: #aaffaa"><a href="./'+date+'/'+date+'.html">'+day+'</a></td>'


openw,1,'/sp_pub/DSTSP_'+year+'.html'
printf,1,res
close,1

;spawn,'scp /home/smart/public_html/T3/T3_'+ffo+'.html 130.54.111.2:/smart3/SMART/T3/'

endif

return

end
;**************************************************************
pro dstvssp_ql_event, ev
;--------------------------------------------------------------
common widgetlib,wparam,windex,refs,refh,time,ha0,zd0,iquvs,hds,radius0,pangle0,incli0,gangle0,lun,iobs

widget_control, ev.id, get_uvalue=uvalue,get_value=value
;print,'uvalue=',uvalue


case uvalue of
	'pqdir':begin
		wparam.pqdir=dialog_pickfile(path=wparam.pqdir,directory=1)
		widget_CONTROL,windex.pqdir,set_value=wparam.pqdir
		wparam.hazddir=wparam.pqdir
		wparam.dir=wparam.pqdir
		widget_CONTROL,windex.hazddir,set_value=wparam.hazddir
		widget_CONTROL,windex.dir,set_value=wparam.dir
		pqfiles=file_search(wparam.pqdir,wparam.pqhead+'.fits',count=nf)
		wparam.npq=nf
		widget_CONTROL,windex.npq,set_value=string(wparam.npq,format='(i)')
	end
	'pqhead':begin
		wparam.pqhead=value
		widget_CONTROL,windex.pqhead,set_value=wparam.pqhead
		pqfiles=file_search(wparam.pqdir,wparam.pqhead+'.fits',count=nf)
		wparam.npq=nf
		widget_CONTROL,windex.npq,set_value=string(wparam.npq,format='(i)')
	end
	'npq':begin
		wparam.npq=value
		widget_CONTROL,windex.npq,set_value=string(wparam.npq,format='(i)')
	end
	'cal_pq':begin
		print,''
		print,'####################################################'
		print,'Start calculation of retardation and offset angle'
		print,'####################################################'
		print,''
		pqfiles=file_search(wparam.pqdir,wparam.pqhead+'.fits',count=nf)
		refs=fltarr(5,wparam.npq)
		for i=0,wparam.npq-1 do begin
		;for i=0,1 do begin
			print,i,wparam.npq-1
			mreadfits,pqfiles[i],h,data,/nodata
			hn=index_form()
			struct_assign,h[0],hn
			if h[0].detnam eq 'GE1650' then begin
			;	reformhd_ge,h[0],hn
				mq=0
			endif else begin
			;	reformhd_xeva,h[0],hn
				mq=1
			endelse
			nx=hn.naxis1
			ny=hn.naxis2
			refs[*,i]=ref2irarp(pqfiles[i],fltarr(nx,ny),0,0,mq=1,header=hn,array=0,ver=1,single=1)
			if i eq 0 then refh=hn else refh=[refh,hn]
		endfor
		print,''
		print,'####################################################'
		print,'Complete calculation of retardation and offset angle'
		print,'####################################################'
		print,''
	end
	'hazddir':begin
		wparam.hazddir=dialog_pickfile(path=wparam.hazddir,directory=1)
		widget_CONTROL,windex.hazddir,set_value=wparam.hazddir
	end
	'read_hazd':begin
		print,''
		print,'####################################################'
		print,'Read Hour angle & Zenith distance'
		print,'####################################################'
		print,''
		txt2hazd,wparam.hazddir,time,ha0,zd0,check=1,radius=radius0,pangle=pangle0,incli=incli0,gangle=gangle0
		print,''
		print,'####################################################'
		print,'Complete reading Hour angle & Zenith distance'
		print,'####################################################'
		print,''
	end
	'dir':begin
		wparam.dir=dialog_pickfile(path=wparam.dir,directory=1)
		widget_CONTROL,windex.dir,set_value=wparam.dir
		files=file_search(wparam.dir,wparam.head+'.fits',count=nf)
		wparam.nfile=nf
		widget_CONTROL,windex.nfile,set_value=string(wparam.nfile,format='(i)')
	end
	'head':begin
		wparam.head=value
		widget_CONTROL,windex.head,set_value=wparam.head
		files=file_search(wparam.dir,wparam.head+'.fits',count=nf)
		wparam.nfile=nf
		widget_CONTROL,windex.nfile,set_value=string(wparam.nfile,format='(i)')
	end
	'nfile':begin
		wparam.nfile=value
		widget_CONTROL,windex.nfile,set_value=string(wparam.nfile,format='(i)')
	end
	'sign': begin
		if value eq 0 then wparam.sign=1. else wparam.sign=-1.
	end
	'show_memo': begin
		memo=file_search(wparam.dir,'memo.txt',count=nf)
		if nf eq 1 then spawn,'emacs '+memo+' -X'
	end
	'cal_iquv':begin
		print,''
		print,'####################################################'
		print,'Make IQUV'
		print,'####################################################'
		print,''
		files=file_search(wparam.dir,wparam.head+'.fits',count=nf)
		if nf eq 0 then goto,jump
		for i=0,wparam.nfile-1 do begin
		;for i=0,4 do begin
			print,i,wparam.nfile-1
			mreadfits,files[i],h,imgs,/nodata
			hn=index_form()
			struct_assign,h[0],hn
			if h[0].detnam eq 'GE1650' then begin
			;	reformhd_ge,h[0],hn
				minus=0
			endif else begin
			;	reformhd_xeva,h[0],hn
				minus=1
				time0=(	float(strmid(hn.date,11,2))+9.)*60d*60d +$
					float(strmid(hn.date,14,2))*60d +$
					float(strmid(hn.date,17,6))
				hn.ha=interpol(ha0,time,time0)
				hn.zd=interpol(zd0,time,time0)
				hn.r=interpol(radius0,time,time0)
				hn.p=interpol(pangle0,time,time0)
				hn.i=interpol(incli0,time,time0)
			endelse
			nx=h[0].naxis1
			ny=h[0].naxis2
			if i eq 0 then iquvs=fltarr(nx*2,ny,wparam.nfile)
			dark=fltarr(nx,ny)
			flat=fltarr(nx,ny)+1.
			pos=selectref(refh,hn)
			if pos[0] ne -1 then begin  
				ii =mean(refs[0,pos])
				rat=mean(refs[1,pos])
				off=mean(refs[2,pos])
				ret=mean(refs[3,pos])
				pol=mean(refs[4,pos])
   		 		dstsp_mkiquv,files[i],ret,off,dark=dark,flat=flat,$
					iquv0,hd,header=hn,fringe=0,ver=1
				if h[0].detnam eq 'GE1650' then begin
					iquv1=iquv0[0:nx/2-1,*,*]
				endif else begin
					iquv1=iquv0[nx/2:nx-1,*,*]
				endelse
				par=par_dst(hd[0])
				imdst=invert(mm_dst(hd,par))
				iquv1[*,*,3]=wparam.sign*iquv1[*,*,3]
				iquv=m44_iquv(imdst,iquv1)
				quv=[iquv[*,*,1],iquv[*,*,2],iquv[*,*,3]]
				iii=iquv[*,*,0]
				mm=minmax(quv)
				iii=iii/(max(iii)-min(iii))*(mm[1]-mm[0])
				iii=iii-min(iii)+mm[0]
				iquvs[*,*,i]=[iii,quv]
				if i eq 0 then hds=hn else hds=[hds,hn]
			endif else print,'no retardation and offset angle'
		endfor
		wdef,0,nx*2,ny
		stepper,reform(iquvs[*,*,*])
		wdelete,0
		print,''
		print,'####################################################'
		print,'Complete IQUV'
		print,'####################################################'
		print,''
		jump:
	end
	"write_html":begin
		print,''
		print,'####################################################'
		print,'Make and add Stokes spectra to HTML file'
		print,'####################################################'
		print,''
;restore,'./tmp.sav'
		yyyy	=strmid(hds[0].date,0,4)
		mm	=strmid(hds[0].date,5,2)
		dd	=strmid(hds[0].date,8,2)
		hh	=strmid(hds[0].date,11,2)
		minu	=strmid(hds[0].date,14,2)
		ss	=strmid(hds[0].date,17,6)

		hh_jst =hh+9.
		if hh_jst ge 24 then begin
			hh_jst=hh_jst-24.
			if (mm eq 1) or (mm eq 3) or (mm eq 5) or (mm eq 7) or (mm eq 8) or (mm eq 10) or (mm eq 12) then maxdd=31
			if (mm eq 2) or (mm eq 4) or (mm eq 6) or (mm eq 9) or (mm eq 11) then maxdd=30
			if mm eq 2 then begin
				if ((yyyy-660) mod 100) eq 0 then begin
					if (((yyyy-660)/100) mod 4) eq 0 then maxdd=29 else maxdd=28
				endif else begin
 					if yyyy mod 4 eq 0 then maxdd=29 else maxdd=28
				endelse
			endif
			if dd lt maxdd then begin
				dd_jst=dd+1
				mm_jst=mm
				yyyy_jst=yyyy
			endif else begin
				dd_jst=1
				if mm eq 12 then begin
					mm_jst=1
					yyyy_jst=yyyy+1
				endif else begin
					mm_jst=mm+1
					yyyy_jst=yyyy
				endelse
			endelse
		endif else begin
			dd_jst=dd
			mm_jst=mm
			yyyy_jst=yyyy
		endelse
		hh_jst=string(hh_jst,format='(i2.2)')
		dd_jst=string(dd_jst,format='(i2.2)')
		mm_jst=string(mm_jst,format='(i2.2)')
		yyyy_jst=string(yyyy_jst,format='(i4.4)')

		dir='/sp_pub/'+yyyy_jst+mm_jst+dd_jst+'/'
		if is_dir(dir) eq 0 then spawn,'mkdir '+dir
		if lun eq -1 then begin
			openw,lun,dir+ yyyy_jst + mm_jst + dd_jst +'.html',/get_lun
			printf,lun,'<html><body bgcolor=white>'
			printf,lun,'<font size=5> DST spectropolarimetric observation on '+ yyyy_jst +'.'+ mm_jst +'.'+ dd_jst +' in JST </font><br>'
			observer='' & read,'Observer : ',observer
			printf,lun,'<font size=4> Observer : '+observer+'<font><br>'

			openw,lun1,dir+'/LOG'+ yyyy_jst + mm_jst + dd_jst +'.html',/get_lun
			printf,lun1,'<html><body bgcolor=white>'
			memo=file_search(wparam.dir,'memo.txt',count=nmemo)
			if nmemo gt 0 then begin 
				for imemo=0,nmemo-1 do begin
					str=''
					openr,lun2,memo[imemo],/get_lun
					while not EOF(lun2) do begin
						readf,lun2,str	
						printf,lun1,'<font size=2>'+str+'</font><br>'
					endwhile
					free_lun,lun2
				endfor
			endif
			printf,lun1,'</body></html>'
			free_lun,lun1
			;spawn,'scp /home/anan/DSTSP_sample/html/LOG'+yyyy+mm+dd+'.html anan@kipsua.kwasan.kyoto-u.ac.jp:/home/anan/public_html/'

			printf,lun,'<font size=4> <a href="http://www.hida.kyoto-u.ac.jp/DST/SP/'+ yyyy_jst + mm_jst + dd_jst +'/LOG'+yyyy_jst + mm_jst + dd_jst +'.html"> Log file </a> <font><br>'

			printf,lun,'<font size=4> <a href="http://www.hida.kyoto-u.ac.jp/DST/his/DST'+ yyyy_jst + mm_jst + dd_jst +'.html"> Slit-jaw movies </a> <font><br>'
			printf,lun,'<hr>'
		endif
		target='' & read,'Target : ',target
		printf,lun,'<font size=4> Target : '+target+'<font><br>'
		printf,lun,'<font size=4> Time in UT  : '+strmid(hds[0].date,11,8)+' - '+strmid(hds[(size(hds))[1]-1].date,11,8)+' </font><br>'
		printf,lun,'<font size=4> Wavelength : '+string(hds[0].wave/10.,format='(i4)')+' nm </font><br>'

		printf,lun,'<table border="1">'

		printf,lun,'<tr>'
		;printf,lun,'<td align=center width=150> Slit-jaw image </td>'
		printf,lun,'<td align=center width=600> Stokes spectra </td>'
		printf,lun,'</tr>'

		;timestr=hds[0].date_obs
		;hh=strmid(timestr,11,2)
		;if hh ge 15 then hh=hh+9-24
		;minu=strmid(timestr,14,2)
		;ss=strmid(timestr,17,2)
		;sttime=hh*60.*60.+minu*60.+ss*1.
		;timestr=hds[(size(hds))[1]-1].date_obs
		;hh=strmid(timestr,11,2)
		;if hh ge 15 then hh=hh+9-24
		;minu=strmid(timestr,14,2)
		;ss=strmid(timestr,17,2)
		;entime=hh*60.*60.+minu*60.+ss*1.
		;hisf=file_search('http://www.hida.kyoto-u.ac.jp/DST/his/'+yyyy+mm+dd+'/jpeg/','*.jpeg',count=nhis)
		;timestr=hisf
		
		if is_dir(dir+'jpeg/') eq 0 then spawn,'mkdir -p '+dir+'jpeg/'
		nx=(size(iquvs))[1]
		ys=0.15
		ye=0.9
		xs=0.1
		xd=0.2
		xdd=0.01
		jpegfiles='jpeg/'+strmid(hds.date,11,2)+strmid(hds.date,14,2)+strmid(hds.date,17,6)+'.jpeg'
		set_plot,'z'
		!p.font=-1
		;device,set_resolution=(size(iquvs))[1:2]*2./3.
		device,set_resolution=[700,500]
		for iii=0,(size(hds))[1]-1 do begin
			print,iii,(size(hds))[1]-1
			;tvscl,iquvs[*,*,iii]
			for jjj=0,3 do begin
				xtitle=''
				ytitle=''
				case jjj of 
					0:begin
						title='I'
						xtitle='slit'
						ytitle='wavelength'
					end
					1:title='Q'
					2:title='U'
					3:title='V'
				endcase
				plot_image,iquvs[jjj*nx/4.:(jjj+1)*nx/4.-1,*,iii],title=title,charsize=1,	$
					norm=1,noerase=jjj,pos=[xs+jjj*(xd+xdd),ys,xs+jjj*(xd+xdd)+xd,ye],	$
					xtickname=replicate(' ',10),ytickname=replicate(' ',10),xtitle=xtitle,ytitle=ytitle
			endfor
			write_jpeg,dir+jpegfiles[iii],tvrd()
		endfor
		set_plot,'x'

		outfile=dir+'stokes'+string(iobs,format='(i2.2)')+'.html'
		jsmovie2,outfile,jpegfiles,title='DST SP'

		printf,lun,'<tr>'
		;printf,lun,'<td align=center width=150> <imgsrc="hoge" height=150 width=150> </td>'
		printf,lun,'<td align=center width=600> <a href="./stokes'+string(iobs,format='(i2.2)')+'.html">'+	$
			'<img src="./jpeg/'+strmid(hds[0].date,11,2)+strmid(hds[0].date,14,2)+strmid(hds[0].date,17.6)+'.jpeg" height=300 width=600> </a></td>'	
		printf,lun,'</tr>'

		iobs=iobs+1	
		printf,lun,'<table clear center>'
		printf,lun,'<hr>'
		print,''
		print,'####################################################'
		print,'Finishing to add Stokes spectra to HTML file'
		print,'####################################################'
		print,''
	end
	"EXIT":begin
		if lun ne -1 then begin
			yyyy	=strmid(hds[0].date,0,4)
			mm	=strmid(hds[0].date,5,2)
			dd	=strmid(hds[0].date,8,2)
			hh	=strmid(hds[0].date,11,2)
			minu	=strmid(hds[0].date,14,2)
			ss	=strmid(hds[0].date,17,6)
			hh_jst=hh+9.
			if hh_jst ge 24 then begin
				hh_jst=hh_jst-24.
				if (mm eq 1) or (mm eq 3) or (mm eq 5) or (mm eq 7) or (mm eq 8) or (mm eq 10) or (mm eq 12) then maxdd=31
				if (mm eq 2) or (mm eq 4) or (mm eq 6) or (mm eq 9) or (mm eq 11) then maxdd=30
				if mm eq 2 then begin
					if ((yyyy-660) mod 100) eq 0 then begin
						if (((yyyy-660)/100) mod 4) eq 0 then maxdd=29 else maxdd=28
					endif else begin
 						if yyyy mod 4 eq 0 then maxdd=29 else maxdd=28
					endelse
				endif
				if dd lt maxdd then begin
					dd_jst=dd+1
					mm_jst=mm
					yyyy_jst=yyyy
				endif else begin
					dd_jst=1
					if mm eq 12 then begin
						mm_jst=1
						yyyy_jst=yyyy+1
					endif else begin
						mm_jst=mm+1
						yyyy_jst=yyyy
					endelse
				endelse
			endif else begin
				dd_jst=dd
				mm_jst=mm
				yyyy_jst=yyyy
			endelse
			hh_jst=string(hh_jst,format='(i2.2)')
			dd_jst=string(dd_jst,format='(i2.2)')
			mm_jst=string(mm_jst,format='(i2.2)')
			yyyy_jst=string(yyyy_jst,format='(i4.4)')

			;printf,lun,'<font size=4> The Stokes spectra are not subtracted dark and not corrected flat fielding.</font><br>'
			;printf,lun,'<font size=4> They are made from one of dual orthogonal spectra, and are calibrated for instrumental polarization by a model whose parameters are measured in June or April, 2012. </font><br>'
			;printf,lun,'<font size=4> If you want to use the data, please contact us.</font><br>'
			;printf,lun,'<font size=4> E-mail: data_info [at] kwasan.kyoto-u.ac.jp</font><br>'
			printf,lun,'</body></html>'
			free_lun,lun

			update_cal_dstsp,yyyy_jst+mm_jst+dd_jst
			spawn,'scp /sp_pub/DSTSP*.html observer@kipsua.kwasan.kyoto-u.ac.jp:/smart3/DST/SP/'
			spawn,'scp -r /sp_pub/'+yyyy_jst+mm_jst+dd_jst+' observer@kipsua.kwasan.kyoto-u.ac.jp:/smart3/DST/SP/'
		endif
		WIDGET_CONTROL, /destroy, ev.top
	end
	else:
endcase

end
;************************************************************************
pro dstvssp_ql
;function dstvssp_ql
;--------------------------------------------------------------
common widgetlib,wparam,windex,refs,refh,time,ha0,zd0,iquvs,hds,radius0,pangle0,incli0,gangle0,lun,iobs


iobs=0
;hazddir=dir+'hazd'
;pqfiles=[(file_search(dir,'XEVA640/ref089*'))[1]]
;files=[(file_search(dir,'XEVA640/scan02*.fits'))[1]]
;sign=-1.

lun=-1
wparam={widget_param, 							$
	pqdir	:	'/mnt/HDD3TBn3/DST/sp/20140702/XEVA640/',	$
	pqhead	:	'ref089*',					$	
	npq	:	0,						$	
	hazddir	:	'/mnt/HDD3TBn3/DST/sp/20140702/hazd/',		$
	dir	:	'/mnt/HDD3TBn3/DST/sp/20140702/XEVA640/',	$	
	head	:	'scan02*',					$
	nfile	:	0,						$
	sign	:	1.						$
	}

windex={widget_index,		$
	pqdir:		0l,	$
	pqhead:		0l,	$
	npq:		0l,	$
	hazddir:	0l,	$
	dir:		0l,	$
	head:		0l,	$
	nfile:		0l,	$
	sign:		0l,	$
	Exit:		0l	$
	}

pqfiles=file_search(wparam.pqdir,wparam.pqhead+'.fits',count=nf)
wparam.npq=nf
files=file_search(wparam.dir,wparam.head+'.fits',count=nf)
wparam.nfile=nf

main = WIDGET_BASE(title='DST/VS/SP QL',/column)

  lab= widget_label(main,value='Retaradation & Offset angle')
  base1=widget_base(main, /column, /frame)
    lab= widget_label(base1,value='Please select data (linear polarizer above slit) and cal.')
    base1_1=widget_base(base1, /row, frame=0)
      lab= widget_label(base1_1,value='Dir: ')
      windex.pqdir=widget_button(base1_1, value=wparam.pqdir, uvalue = "pqdir",	$
				/align_left,xsize=300,ysize=30)
    base1_2=widget_base(base1, /row, frame=0)
      lab= widget_label(base1_2,value='File name: ')
      windex.pqhead=widget_text(base1_2,value=wparam.pqhead, $
				xsize=10, ysize=1, uvalue='pqhead',/edit)
      lab= widget_label(base1_2,value='.fits    # of files')
      windex.npq=widget_text(base1_2,value=string(wparam.npq,format='(i)'), $
				xsize=10, ysize=1, uvalue='npq',/edit)
    base1_3=widget_base(base1, /row, frame=0)
      bt=widget_button(base1_3, value='Calculation', uvalue = "cal_pq",	$
				/align_center,xsize=100,ysize=30)

  lab= widget_label(main,value='Hour Angle & Zenith distance (only XEVA640)')
  base2=widget_base(main, /column, /frame)
    lab= widget_label(base2,value='Please select directory and read')
    base2_1=widget_base(base2, /row, frame=0)
      lab= widget_label(base2_1,value='Dir: ')
      windex.hazddir=widget_button(base2_1, value=wparam.hazddir, uvalue = "hazddir",	$
				/align_left,xsize=300,ysize=30)
    base2_2=widget_base(base2, /row, frame=0)
      bt=widget_button(base2_2, value='Read', uvalue = "read_hazd",	$
				/align_center,xsize=100,ysize=30)

  lab= widget_label(main,value='Stokes spectra')
  base3=widget_base(main, /column, /frame)
    lab= widget_label(base3,value='Please select data and cal.')
    base3_1=widget_base(base3, /row, frame=0)
      lab= widget_label(base3_1,value='Dir: ')
      windex.dir=widget_button(base3_1, value=wparam.dir, uvalue = "dir",	$
				/align_left,xsize=300,ysize=30)
    base3_2=widget_base(base3, /row, frame=0)
      lab= widget_label(base3_2,value='File name: ')
      windex.head=widget_text(base3_2,value=wparam.head, $
				xsize=10, ysize=1, uvalue='head',/edit)
      lab= widget_label(base3_2,value='.fits    # of files')
      windex.nfile=widget_text(base3_2,value=string(wparam.nfile,format='(i)'), $
				xsize=10, ysize=1, uvalue='nfile',/edit)

    base3_3=widget_base(base3, /row, frame=0)
    bt=widget_button(base3_3, value='memo.txt', uvalue = "show_memo",	$
				/align_center,xsize=100,ysize=30)

    base3_4=widget_base(base3, /column, /frame)
    base3_4_1=widget_base(base3_4, /row, frame=0)
      bt=widget_button(base3_4_1, value='Calculation', uvalue = "cal_iquv",	$
				/align_center,xsize=100,ysize=30)
      signv=['+V','-V']
      windex.sign=cw_bselector(base3_4_1,signv,label_left='Sign V: ', $
				uvalue="sign",set_value=0, ysize=1)

;    base3_5=widget_base(base3, /row, frame=0)
    bt=widget_button(base3_4, value='Write Stokes spectra on HTML file', uvalue = "write_html",	$
				/align_center,xsize=300,ysize=30)


windex.Exit = widget_button(main, value="Exit", uvalue = "EXIT")
widget_control, main, /realize
XMANAGER,'dstvssp_ql',main,modal=modal

;return,iquvs


END
