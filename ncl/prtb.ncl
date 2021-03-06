;----------------------------------------------------------------------
; vector_1.ncl
;
; Concepts illustrated:
;   - Overlaying vectors and filled contours on a map
;   - Manually attaching lat/lon coordinate arrays to a variable
;   - Changing the length of the smallest vector as a fraction of the reference vector
;   - Moving the vector reference annotation to the top right of the plot
;   - Drawing curly vectors
;   - Setting the color for vectors
;   - Making the labelbar be vertical
;   - Increasing the thickness of vectors
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

begin

;---Open netCDF file
  mem = "05"
  a = addfile("../../netcdf/tigge/2019/jma/100912_mean.nc","r")
  b = addfile("../../netcdf/tigge/2019/jma/100912_"+mem+".nc","r")
;
; Read in Sea Surface Temperature Anomalies
; Read in U and V at 1000 mb [subscript 0]
; Determine the subscripts corresponding to Jan 88
;
  u00      = a->UGRD(:,:,:,:)
  v00      = a->VGRD(:,:,:,:)
  t00      = a->TMP(:,:,:,:)
  q00      = a->SPFH(:,:,:,:)
  ps00     = a->PRES_meansealevel(:,:,:)
  z00      = a->HGT(:,:,:,:)
  u12      = b->UGRD(:,:,:,:)
  v12      = b->VGRD(:,:,:,:)
  t12      = b->TMP(:,:,:,:)
  q12      = b->SPFH(:,:,:,:)
  ps12     = b->PRES_meansealevel(:,:,:)
  z12      = b->HGT(:,:,:,:)
  lat_uv   = a->lat
  lon_uv   = a->lon
  plev     = a->level
  time_00   = a->time
  time_12   = b->time
  date_00  = cd_string(time_00, "%Y%N%D%H")
  date_12  = cd_string(time_12, "%Y%N%D%H")
  lon0 = 120.
  lon1 = 180.
  lat0 = 0.
  lat1 = 60.
  
  out = "prtb_mem"+mem
;  wks = gsn_open_wks("png","prtb_mem26")
;  plot = new(4,graphic)
  cmap = read_colormap_file("hotcold_18lev")
    
  vdate = 2019100912
  ind_00 = ind(date_00.eq.vdate)
  ind_12 = ind(date_12.eq.vdate)
  ps = ps12(ind_12,:,:)
  ps = ps12(ind_12,:,:) - ps00(ind_00,:,:)
  pful = ps00(ind_12,:,:)
  wks = gsn_open_wks("pdf",out+"_slp")
  resps                = True               ; plot mods desired
  resps@gsnDraw	      = False
  resps@gsnFrame	      = False
;   res@cnInfoLabelOn	      = False
     
  resps@gsnCenterString	   = "slp"
  resps@gsnCenterStringOrthogonalPosF = 0.02
  resps@gsnLeftString	    = ""
  resps@gsnRightString	    = ""
  resps@gsnAddCyclic	      = False
  resps@cnFillOn             = True               ; turn on color for contours
  resps@cnLinesOn            = False              ; turn off contour lines
  resps@cnLineLabelsOn       = False              ; turn off contour line labels
  resps@gsnScalarContour     = True               ; contours desired
  resps@cnFillPalette        = cmap

  resps@mpLandFillColor      = "gray"            ; set land to be gray
  resps@mpMinLonF            =  lon0               ; select a subregion
  resps@mpMaxLonF            =  lon1
  resps@mpMinLatF            =  lat0
  resps@mpMaxLatF            =  lat1

  resps@lbOrientation            = "Vertical"     ; vertical label bar
  resps@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer

; note, when doing a subregion, NCL determines the range of the data from
; the full domain. If you wish to just consider the domain you are plotting,
; you must manually set those levels.

  resps@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
;     res@cnMaxLevelCount	   = 10
  resps@cnMinLevelValF       = -150.              ; set min contour level
  resps@cnMaxLevelValF       = 150.                 ; set max contour level
  resps@cnLevelSpacingF      = 10.             ; set contour spacing

  plotp = gsn_csm_contour_map(wks, ps, resps)

  resps@cnFillOn             = False             ; turn on color for contours
  resps@cnLinesOn            = True              ; turn off contour lines
  resps@cnLineLabelsOn       = True
  resps@cnLevelSelectionMode = "ManualLevels"    ; set manual contour levels
   ;resps@cnMaxLevelCount	   = 10
  resps@cnMinLevelValF       = 96000.0              ; set min contour level
  resps@cnMaxLevelValF       = 108000.0                 ; set max contour level
  resps@cnLevelSpacingF      = 400.0               ; set contour spacing
; when using the gsn_csm plot templates and overlay, it is necessary to
; turn off the automatic label strings so that you don't get text on 
; top of text
  resps@gsnRightString   = ""    
  resps@gsnLeftString    = ""
  resps@gsnCenterString  = ""
      
  plotpf = gsn_csm_contour(wks,pful,resps)
  overlay(plotp,plotpf)
  ;plot(0) = plotp
  draw(plotp)
  frame(wks)
  delete(plotp)
  delete(plotpf)
  do k = 0,2
     u = u12(ind_12,k,:,:)
     u = u12(ind_12,k,:,:) - u00(ind_00,k,:,:) 
     v = v12(ind_12,k,:,:)
     v = v12(ind_12,k,:,:) - v00(ind_00,k,:,:)
     t = t12(ind_12,k,:,:)
     t = t12(ind_12,k,:,:) - t00(ind_00,k,:,:)
     q = q12(ind_12,k,:,:)
     q = q12(ind_12,k,:,:) - q00(ind_00,k,:,:)
     q = q*10^3
     z = z00(ind_00,k,:,:);z12(ind_12,k,:,:)
     ;z = z12(ind_12,k,:,:) - z00(ind_00,k,:,:)
     hgt = plev(k)
     wks = gsn_open_wks("pdf",out+"_"+hgt)
;---Create plot
     res                = True               ; plot mods desired
     res@gsnDraw	      = False
     res@gsnFrame	      = False
;     res@cnInfoLabelOn	      = False
     
     res@gsnCenterString	   = "T,q+wind_"+hgt+"hPa"
     res@gsnCenterStringOrthogonalPosF = 0.02
     res@gsnLeftString	    = ""
     res@gsnRightString	    = ""
     res@gsnAddCyclic	      = False
     res@cnFillOn             = True               ; turn on color for contours
     res@cnLinesOn            = False              ; turn off contour lines
     res@cnLineLabelsOn       = False              ; turn off contour line labels
     res@gsnScalarContour     = True               ; contours desired
     res@cnFillPalette        = cmap

;     res@mpLandFillColor      = "gray"            ; set land to be gray
     res@mpFillOn	      = False
     res@mpMinLonF            =  lon0               ; select a subregion
     res@mpMaxLonF            =  lon1
     res@mpMinLatF            =  lat0
     res@mpMaxLatF            =  lat1

     res@lbOrientation            = "Vertical"     ; vertical label bar
     res@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer

; note, when doing a subregion, NCL determines the range of the data from
; the full domain. If you wish to just consider the domain you are plotting,
; you must manually set those levels.

      res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
;     res@cnMaxLevelCount	   = 10
      res@cnMinLevelValF       = -2.0               ; set min contour level
      res@cnMaxLevelValF       = 2.0                 ; set max contour level
      res@cnLevelSpacingF      = 0.25               ; set contour spacing

      res@vcRefMagnitudeF           = 5.0             ; define vector ref mag
      res@vcRefLengthF              = 0.045           ; define length of vec ref
      res@vcRefAnnoOrthogonalPosF   = -1.0            ; move ref vector
      res@vcRefAnnoArrowLineColor   = "black"         ; change ref vector color
      res@vcRefAnnoArrowUseVecColor = False           ; don't use vec color for ref

;     res@vcMinMagnitudeF	      = 1.0		  ; no effect with CurlyVector
      res@vcGlyphStyle            = "CurlyVector"     ; turn on curly vectors
      res@vcLineArrowColor        = "black"           ; change vector color
      res@vcLineArrowThicknessF   = 2.0               ; change vector thickness
      res@vcMinDistanceF	      = 0.02
      res@vcVectorDrawOrder       = "PostDraw"        ; draw vectors last

      wind = sqrt(u^2+v^2)
      u = where(wind.lt.0.5, u@_FillValue, u)
  
      plott = gsn_csm_vector_scalar_map_ce(wks,u,v,t,res)

      res@cnFillOn             = False             ; turn on color for contours
      res@cnLinesOn            = True              ; turn off contour lines
      res@cnLineLabelsOn       = True
      res@cnLineColor          = "blue"
      res@gsnContourZeroLineThicknessF = 0. 	  ; doubles thickness of zero contour
      res@gsnContourNegLineDashPattern = 1 	  ; sets negative contours to dash pattern 1
      res@cnLevelSelectionMode = "ManualLevels"    ; set manual contour levels
;     res@cnMaxLevelCount	   = 10
      res@cnMinLevelValF       = -3.0             ; set min contour level
      res@cnMaxLevelValF       = 3.0                 ; set max contour level
      res@cnLevelSpacingF      = 0.5               ; set contour spacing
; when using the gsn_csm plot templates and overlay, it is necessary to
; turn off the automatic label strings so that you don't get text on 
; top of text
      res@gsnRightString   = ""    
      res@gsnLeftString    = ""
      res@gsnCenterString  = ""
      
      plotq = gsn_csm_contour(wks,q,res)
      overlay(plott,plotq)

      res@cnFillOn             = False             ; turn on color for contours
      res@cnLinesOn            = True              ; turn off contour lines
      res@cnLineLabelsOn       = True
      res@cnLineColor          = "black"
      res@gsnContourZeroLineThicknessF = 0. 	  ; doubles thickness of zero contour
      res@gsnContourNegLineDashPattern = 1 	  ; sets negative contours to dash pattern 1
      res@cnLevelSelectionMode = "ManualLevels"    ; set manual contour levels
      ;res@cnMaxLevelCount	   = 10
      if (k .eq. 0) then
         res@cnMinLevelValF       = 1200.0              ; set min contour level
         res@cnMaxLevelValF       = 1500.0                 ; set max contour level
         res@cnLevelSpacingF      = 30.0               ; set contour spacing
      end if
      if (k .eq. 1) then
         res@cnMinLevelValF       = 5200.0              ; set min contour level
         res@cnMaxLevelValF       = 5800.0                 ; set max contour level
         res@cnLevelSpacingF      = 50.0               ; set contour spacing
      end if
      if (k .eq. 2) then
         res@cnMinLevelValF       = 8800.0              ; set min contour level
         res@cnMaxLevelValF       = 9600.0                 ; set max contour level
         res@cnLevelSpacingF      = 80.0               ; set contour spacing
      end if
; when using the gsn_csm plot templates and overlay, it is necessary to
; turn off the automatic label strings so that you don't get text on 
; top of text
      res@gsnRightString   = ""    
      res@gsnLeftString    = ""
      res@gsnCenterString  = ""
      
      plotz = gsn_csm_contour(wks,z,res)
      overlay(plott,plotz)
      draw(plott)
      frame(wks)
      ;plot(k+1) = plott
      delete(plott)
      delete(plotq)
      delete(plotz)
   end do

;   resP	                   = True
;   resP@gsnPanelMainString	   = "perturbation member 26 T&Q&wind,slp "+vdate
;   gsn_panel(wks,plot,(/1,4/),resP)
end
