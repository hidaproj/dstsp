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

## widget 
