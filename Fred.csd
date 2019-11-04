Dust.csd
Written by Iain McCurdy, 2013.

A simple encapsulation of the 'dust' opcode.
Added features are stereo panning (spread) of the dust, a random tonal variation (lowpass filter with jumping cutoff frequency) and constant low and highpass filters.


<Cabbage>
form caption("Fred"), size(510, 80), pluginid("dust") style("legacy")
image    bounds(0, 0, 510, 80), , , , outlinethickness(2) colour(0, 255, 0, 128)
image    bounds(0, 0, 510, 80), file("Screen Shot 2019-11-04 at 15.27.38.png"), , , , outlinethickness(2) colour(0, 255, 0, 128)
checkbox bounds(10, 10, 80, 15), text("On/Off"), channel("onoff"), , fontcolour:0(255, 255, 255, 255) fontcolour:1(0, 0, 0, 255)
rslider  bounds( 70, 10, 60, 60), text("Power"), channel("power"),     range(0, 1.00, 0.5, 0.5, 0.001),   textcolour("white"), colour(105, 20, 20), outlinecolour(155,100,100), trackercolour(220,160,160)
rslider  bounds(125, 10, 60, 60), text("Scrub"),     channel("scrub"),    range(0.1, 20000, 500, 0.5, 0.01), textcolour("white"), colour(105, 20, 20), outlinecolour(155,100,100), trackercolour(220,160,160)
rslider  bounds(180, 10, 60, 60), text("Depth"),    channel("depth"),  range(0, 1.00, 1),                 textcolour("white"), colour(105, 20, 20), outlinecolour(155,100,100), trackercolour(220,160,160)
rslider  bounds(235, 10, 60, 60), text("Density"), channel("density"), range(0, 1.00, 0),                 textcolour("white"), colour(105, 20, 20), outlinecolour(155,100,100), trackercolour(220,160,160)
rslider  bounds(290, 10, 60, 60), text("Lowpass"),   channel("LPF"),     range(20,20000,20000,0.5),         textcolour("white"), colour(105, 20, 20), outlinecolour(155,100,100), trackercolour(220,160,160)
rslider  bounds(345, 10, 60, 60), text("Highpass"),  channel("HPF"),     range(20,20000,20,0.5), textcolour("white"), colour(105, 20, 20), outlinecolour(155,100,100), trackercolour(220,160,160)
rslider bounds(400, 10, 60, 60), text("Modulation"), channel("modFreq"), range(0, 14, 0.5),textcolour("white") , colour(105, 20, 20, 255), outlinecolour(155, 100, 100, 255), trackercolour(220, 160, 160, 255)
rslider bounds(450, 10, 60, 60), text("Strength"), channel("inten"), range(0, 10, 1), textcolour("white"), colour(105, 20, 20), outlinecolour(155,100,100), trackercolour(220,160,160)
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-dm0 -n -+rtmidi=null -M0
</CsOptions>

<CsInstruments>

;sr is set by the host
ksmps 		= 	64
nchnls 		= 	2
0dbfs		=	1	;MAXIMUM AMPLITUDE
massign	0,0

instr	1
	konoff	chnget	"onoff"	;read in on/off switch widget value
	printk2 konoff, 1
	if konoff==0 goto SKIP		;if on/off switch is off jump to 'SKIP' label
	kamp	chnget	"power"
	kfreq	chnget	"scrub"
	kspread	chnget	"depth"
	asig	dust2	kamp, kfreq	;GENERATE 'dust2' IMPULSES
	
	; tone variation
	kToneVar	chnget	"density"
	if(kToneVar>0) then
 	 kcfoct	random		14-(kToneVar*10),14
	 asig	tonex		asig,cpsoct(kcfoct),1
	endif

	kpan	random	0.5-(kspread*0.5), 0.5+(kspread*0.5)
	asigL,asigR	pan2	asig,kpan

	kporttime	linseg	0,0.001,0.05

	; Lowpass Filter
	kLPF	chnget	"LPF" 
	if kLPF<20000 then
	 kLPF	portk	kLPF,kporttime
	 asigL	clfilt	asigL,kLPF,0,2
	 asigR	clfilt	asigR,kLPF,0,2
	endif
	
	; Highpass Filter
	kHPF	chnget	"HPF"
	if kHPF>20 then
	 kHPF	limit	kHPF,20,kLPF
	 kHPF	portk	kHPF,kporttime
	 asigL	clfilt	asigL,kHPF,1,2
	 asigR	clfilt	asigR,kHPF,1,2
	endif
	
	; Modulation
	kMod chnget "modFreq"
	kIntens chnget "inten"
    aLFOL lfo kIntens, kMod, 0
    aLFOR lfo kIntens, kMod, 0
    

		outs	asigL*aLFOL,asigR*aLFOR	;SEND AUDIO SIGNAL TO OUTPUT
	SKIP:				;A label. Skip to here if on/off switch is off 

endin


</CsInstruments>

<CsScore>
i 1 0 [60*60*24*7]	;instrument that reads in widget data
</CsScore>

</CsoundSynthesizer>