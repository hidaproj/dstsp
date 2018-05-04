`print,'uvalue=',uvalue`

every time we change widget's value, print the value on the screen?

`dir1='/sp_pub/save/'`:

directory to output `*.sav` files

`azimuth=1`

unknown.

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

```
		wparam.dir=dialog_pickfile(path=wparam.dir,directory=1)
		widget_CONTROL,windex.dir,set_value=wparam.dir
		wparam.hazddir=wparam.dir
		widget_CONTROL,windex.hazddir,set_value=wparam.hazddir
```

`wparam.dir` and `wparam.hazddir` are initialized to for example "/mnt/HDD3TBn17/DST/sp/20170827/camera02".
