pro tgf_lis_timecomp
;+ The following is a program to narrow the candidates for data from the lis satelite relative to TGF events supplied by FERMI. Time is converted from TAI93 to UTC by the /UTC keyword in the lis_data command.
; Each file from the lis satelite is compared against each potential time from the TGF data.
; Time from the lis satelite is in UTC seconds since 1 January 1970 at 00:00:00
; 
files=file_search('/home/tdaught/TGF/Data/LIS Data/*',count=nfiles)
tgf_data='/home/tdaught/TGF/text/TGFs_Reliable_through_2013.WWLLN_and_ENTLN.txt'
r=rd_tfile(tgf_data,/nocomment,/auto)

tgf_raw_id=r[0,*]
tgf_raw_met=r[1,*]
tgf_raw_date=r[2,*]
tgf_raw_time=r[3,*]

for i=0,nfiles-1 do begin
lisData=read_lis(files[i],/UTC,/ORBIT_SUMMARY)
arr_t=lisData.orbit_summary.utc_start
t=float(arr_t)
lis_file=files[i]

for j=0,876 do begin
tgf_id=tgf_raw_id[j]
tgf_yr_str=strmid(tgf_raw_date[j],0,4)
tgf_mo_str=strmid(tgf_raw_date[j],5,2)
tgf_day_str=strmid(tgf_raw_date[j],8,2)
tgf_hr_str=strmid(tgf_raw_time[j],0,2)
tgf_min_str=strmid(tgf_raw_time[j],3,2)
tgf_sec_str=strmid(tgf_raw_time[j],6,2)
tgf_milsec_str=strmid(tgf_raw_time[j],9,6)

tgf_yr=float(tgf_yr_str)
tgf_mo=float(tgf_mo_str)
tgf_day=float(tgf_day_str)
tgf_hr=float(tgf_hr_str)
tgf_min=float(tgf_min_str)
tgf_sec=float(tgf_sec_str)
tgf_milsec=float(tgf_milsec_str)
;MJD is used to give day differences and then seconds are converted from there. A 1.6 hour range is used to account for any innacuracies in data.
tgf_MDJ=date2MJD(tgf_yr,tgf_mo,tgf_day)+(tgf_hr/24)+(tgf_min/1440)+(tgf_sec/86400)+(tgf_milsec/86400000)
utcref_MJD=date2MJD(1970,01,01)+0.000000000000000
diff_days=tgf_MDJ-utcref_MJD
tgf_time_sec = diff_days*86400

diff_sec=(tgf_time_sec)-t
diff_hrs=diff_sec/3600
abs_diff_hrs=ABS(diff_hrs)
;print,abs_diff_hrs

if abs_diff_hrs LE 1.6 then begin
	date=tgf_yr_str+'.'+tgf_mo_str+'.'+tgf_day_str
	FILE_MKDIR,'/home/tdaught/TGF/Data/'+date
	FILE_MOVE, [files[i]],'/home/tdaught/TGF/Data/'+date
	print, tgf_id, abs_diff_hrs, lis_file
	print,'Eureka!'
	endif
endfor
endfor
end
