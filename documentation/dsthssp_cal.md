## begining

`print,'uvalue=',uvalue`

every time we change widget's value, print the value on the screen?

`dir1='/sp_pub/save/'`:

directory to output `*.sav` files

`azimuth=1`

unknown.

## widget `camera`

```
'camera':begin
	case value of 
		0:wparam.camera='orca4'
		1:wparam.camera='xeva640'
		2:wparam.camera='ge1650'
	endcase
print,wparam.camera
end
```

select which camera we used, since different camera has different property of detecting photons.

## widget `dir`

```
wparam.dir=dialog_pickfile(path=wparam.dir,directory=1)
widget_CONTROL,windex.dir,set_value=wparam.dir
wparam.hazddir=wparam.dir
widget_CONTROL,windex.hazddir,set_value=wparam.hazddir
```

`wparam.dir` and `wparam.hazddir` are initialized to for example `'/mnt/HDD3TBn17/DST/sp/20170827/camera02'`.

```
pqfiles=file_search(wparam.dir,wparam.pq_file+'.fits',count=nf)
wparam.npq=nf
widget_CONTROL,windex.npq,set_value=string(wparam.npq,format='(i)')
```

since `wparam.pq_file` has been initialized to `'ref*'`, these code read fits filename of `+Q` reference data and the file count. `pq` is related to `+Q`, i.e., plus Q. After that the count `wparam.npq` is shown in widget `windex.npq` with `format='(i)'` since `wparam.npq` is an integer.

```
date=strmid(wparam.dir,strpos(wparam.dir,'/DST/sp/')+8,8)
subdir=strmid(wparam.dir,strpos(wparam.dir,'/DST/sp/')+17,strlen(wparam.dir)-(17+strpos(wparam.dir,'/DST/sp/')))
dir=dir0+date+'/'
svdir=dir1+date+'/'+subdir
svdir1=dir1+date+'/'
if is_dir(dir) eq 0 then spawn,'mkdir '+dir
if is_dir(svdir1) eq 0 then spawn,'mkdir '+svdir1
if is_dir(svdir) eq 0 then spawn,'mkdir '+svdir
```

`date` a string like `20170827`; `subdir` is the folder name where fits files are saved for example `camera02`. Then `dir` is `/sp_pub/20170827/`; `svdir` is `/sp_pub/save/20170827/camera02`; `svdir1` is `/sp_pub/save/20170827`.

After that, create folder which does not exist.

## widget `ref_index`

```
'ref_index':begin
	wparam.ref_index=value
	widget_CONTROL,windex.ref_index,set_value=wparam.ref_index
end
```
enter the filename string of reference index?

this widget is for calibration data, whose usage is still unknown.

## widget `dark_file`

```
'drk_file':begin
	wparam.drk_file=value
	widget_CONTROL,windex.drk_file,set_value=wparam.drk_file
	drkfiles=file_search(wparam.dir,wparam.drk_file+'.fits',count=nf)
	wparam.ndrk=nf
	widget_CONTROL,windex.ndrk,set_value=string(wparam.ndrk,format='(i)')
end
```

enter the filename string, for example `'dark*'`, to search for fits file of dark. string list of dark fits filename and its counting are stored in `drkfiles` and `wparam.ndrk`.

## widget `ndrk`

```
'ndrk':begin
	wparam.ndrk=value
	widget_CONTROL,windex.ndrk,set_value=string(wparam.ndrk,format='(i)')
end
```

when we want to define the how many dark files we want to use manually we would change this value, or it will be the counting of all dark fits files.

## widget `flat_file`

```
'flat_file':begin
	wparam.flat_file=value
	widget_CONTROL,windex.flat_file,set_value=wparam.flat_file
	flatfiles=file_search(wparam.dir,wparam.flat_file+'.fits',count=nf)
	wparam.nflat=nf
	widget_CONTROL,windex.nflat,set_value=string(wparam.nflat,format='(i)')
end
```

similar to widget `dark_file`, search flat fits files and count them.

## widget `nflat`

```
'nflat':begin
	wparam.nflat=value
	widget_CONTROL,windex.nflat,set_value=string(wparam.nflat,format='(i)')
end
```

similar to widget `ndrk`, manually change how many flat files we want to use.

## widget `pq_file`

```
'pq_file':begin
	wparam.pq_file=value
	widget_CONTROL,windex.pq_file,set_value=wparam.pq_file
	pqfiles=file_search(wparam.dir,wparam.pq_file+'.fits',count=nf)
	wparam.npq=nf
	widget_CONTROL,windex.npq,set_value=string(wparam.npq,format='(i)')
end
```

similar to widget `dark_file`, search plus Q fits files and count them.

## widget `npq`

```
'npq':begin
	wparam.npq=value
	widget_CONTROL,windex.npq,set_value=string(wparam.npq,format='(i)')
end
```
similar to widget `ndrk`, manually change how many flat files we want to use.

## widget `merginx`

skip. it is set to `5` defaultly in other program.

## widget `merginy`

skip. it is set to `5` defaultly in other program.

## widget `skipkxky`

skip. normally we do not skip the calculation of `kx` and `ky`.

## widget `hazddir`

```
'hazddir':begin
	wparam.hazddir=dialog_pickfile(path=wparam.hazddir,directory=1)
	widget_CONTROL,windex.hazddir,set_value=wparam.hazddir
end
```

select folder of hazd txt files

## widget `prep_dark`

```
files=(file_search(wparam.dir,wparam.drk_file+'.fits',count=nf))[0:wparam.ndrk-1]
dstsp_mkdark,files[0:wparam.ndrk-1],wparam.camera,darks,dh
save,darks,dh,file=svdir+'dark.sav'
```

1. search for the first `wparam.ndrk` dark fits files
2. calculate `darks` and `dh` with program `dstsp_mkdark`
3. save `darks` and `dh` to for example `/sp_pub/save/20170827/camera02`, named `dark.sav`.

> `dstsp_mkdark` comes from [https://github.com/hidaproj/dstsp/blob/master/idl/polarimeterlib_v3.pro#L339](https://github.com/hidaproj/dstsp/blob/master/idl/polarimeterlib_v3.pro#L339). still not sure what is going on inside this program. `dh`? index-like variable?

## widget `prep_ref`

first we calculate `KXKY`:

```
file=(file_search(wparam.dir,wparam.pq_file+'.fits',count=nf))[0:wparam.npq-1]
nf=wparam.npq
kx=fltarr(2,2,nf)
ky=fltarr(2,2,nf)
shiftx1=fltarr(nf)
ii=0
for i=0,nf-1 do begin
	if (ii eq 0) then begin
		dstsp_mkkxky,file[i],merginx=wparam.merginx,merginy=wparam.merginy,   $
		    offx=0,offy=0,camera=wparam.camera,	$;keywords
		    kx0,ky0,shiftx10,kxkyh0,outfile=0
		ans=''
		read,'save this result? y or n: ',ans
		if ans eq 'y' then begin
			kxkyh=kxkyh0
			kx[*,*,ii]=kx0
			ky[*,*,ii]=ky0
			shiftx1[ii]=shiftx10
			ii=ii+1
		endif

	endif else begin
	;; lots fo code here
	endelse
endfor
```

`ii` is 0 until we enter `y` to confirm `kx` and `ky` calculated by program `dstsp_mkkxky`, so before we are satisfied we will be here again and again, running `i` from `0` to `nf-1`. `ii` is the index to identify which `kx` and `ky` work better.

> `dstsp_mkkxky`, does the image restoration and position alignment.

once `ii` is not `0`, we will move on to the next part, and will never go back to this part. in the next part, we will test whether the calculated `kx` and `ky` work well for other `ref*.fits` data.

```
for i=0,nf-1 do begin
	if (ii eq 0) then begin
		;; lots of code here
	endif else begin
		case wparam.camera of
			'ge1650':mreadfits,file[i],index,data,/nodata
			'xeva640':begin
				mreadfits,file[i],index,data,/nodata
					index=dstsp_mkindex(header=index,ver=2,    $
					az=fltarr(n_elements(index)),imgrot=fltarr(n_elements(index)))
				end
			'orca4':begin
				read_orca,file[i],index,data,/nodata
					index=dstsp_mkindex(header=index,ver=1,    $
					az=fltarr(n_elements(index)),imgrot=fltarr(n_elements(index)))
				end
			endcase
		;; lots of code here
	endelse
endfor
```

according to which camera we used, we do or do not use function `dstsp_mkindex` to re-read variable `index`.

> `dstsp_mkindex`, from [https://github.com/hidaproj/dstsp/blob/master/idl/polarimeterlib_v3.pro#L44](https://github.com/hidaproj/dstsp/blob/master/idl/polarimeterlib_v3.pro#L44), also appeared inside program `dstsp_mkdark`. I don't know what it is for.

after this, we move on to 

```
for i=0,nf-1 do begin
	if (ii eq 0) then begin
		;; lots of code here
	endif else begin
		;; lots of code here
		
		pos=selectkxky(kxkyh,index[0])
		if pos[0] eq -1 then begin
			dstsp_mkkxky,file[i],merginx=wparam.merginx,merginy=wparam.merginy, $
								   offx=0,offy=0,camera=wparam.camera, $;keywords
			   kx0,ky0,shiftx10,kxkyh0,outfile=0
			ans=''
			read,'save this result? y or n: ',ans
			if ans eq 'y' then begin
				kx[*,*,ii]=kx0
				ky[*,*,ii]=ky0
				shiftx1[ii]=shiftx10
				kxkyh=[kxkyh,kxkyh0]	
				ii=ii+1
			endif
		endif
	endelse
endfor
```

if `pos[0] eq -1` which means the calculated `kx` and `ky` do not fit in well, we re-calculate `kx` and `ky` and then save into `ii`th `kx`,`ky` array.

```
kx=kx[*,*,0:ii-1]
ky=ky[*,*,0:ii-1]
shiftx1=shiftx1[0:ii-1]
kxkyh=kxkyh[0:ii-1]
save,kx,ky,shiftx1,kxkyh,file=svdir+'kxky.sav'
```

then we save those `kx`, `ky` which works well, and `shiftx1`, `kxkyh`.

> what about those `ref*.fits` dataset without good `kx` and `ky`? here we do not have any variable to separate good data and bad data. `ii` is simply a counter.

after restoration and alignment, we move on to the calculation of the retardation and offset angle of analyzer.
