/**************************************************************************
 Program:  Hud_inc_22_dmped.sas
 Library:  DMPED
 Project:  Urban Greater DC
 Author:   Alexa Kort
 Created:  6/4/2024
 Version:  SAS 9.4
 Environment:  Windows
 
 Description:  Autocall macro to calculate HUD income categories for
 IPUMS data, variable HUD_INC.
 
 Values:
 1  =  <=30% AMI (extremely low)
 2  =  31-50% AMI (very low)
 3  =  51-80% AMI (low)
 4  =  81-120% AMI (middle)
 5  =  120-200% AMI (high)
 6  =  >=200% (extremely high)
 7  =  N/A (income not reported)

 Modifications: AK Modifying hud_inc_2022 macro from IPUMS library to have 6th income category >200% AMI
**************************************************************************/

/** Macro Hud_inc_<year> - Start Definition **/

%macro Hud_inc_2022_dmped( hhinc=hhincome, hhsize=numprec );

  ** HUD income categories (<year>) **;

  if (&hhinc.) in ( 9999999, .n ) then hud_inc = .n;
  else do;

           select ( numprec );
      when ( 1 )
        do;
          if hhincome <= 29900 then hud_inc = 1;
          else if 29900 < hhincome <= 49850 then hud_inc = 2;
          else if 49850 < hhincome <= 63000 then hud_inc = 3;
          else if 63000 < hhincome <= 119640 then hud_inc = 4;
          else if 119640 < hhincome <= 2*(49850/0.5)then hud_inc = 5;
		  else if 2*(49850/0.5) < hhincome then hud_inc = 6;/*200% plus*/
        end;
      when ( 2 )
        do;
          if hhincome <= 34200 then hud_inc = 1;
          else if 34200 < hhincome <= 56950 then hud_inc = 2;
          else if 56950 < hhincome <= 72000 then hud_inc = 3;
          else if 72000 < hhincome <= 136680 then hud_inc = 4;
          else if 136680 < hhincome <= 2*(56950/0.5) then hud_inc = 5;
		  else if 2*(56950/0.5) < hhincome then hud_inc = 6;/*200% plus*/
        end;
      when ( 3 )
        do;
          if hhincome <= 38450 then hud_inc = 1;
          else if 38450 < hhincome <= 64050 then hud_inc = 2;
          else if 64050 < hhincome <= 81000 then hud_inc = 3;
          else if 81000 < hhincome <= 153720 then hud_inc = 4;
          else if 153720 < hhincome <= 2*(64050/0.5) then hud_inc = 5;
		  else if 2*(64050/0.5) < hhincome then hud_inc = 6;/*200% plus*/
        end;
      when ( 4 )
        do;
          if hhincome <= 42700 then hud_inc = 1;
          else if 42700 < hhincome <= 71150 then hud_inc = 2;
          else if 71150 < hhincome <= 90000 then hud_inc = 3;
          else if 90000 < hhincome <= 170760 then hud_inc = 4;
          else if 170760 < hhincome <= 2*(71150/0.5) then hud_inc = 5;
		  else if 2*(71150/0.5) < hhincome then hud_inc = 6;/*200% plus*/
        end;
      when ( 5 )
        do;
          if hhincome <= 46150 then hud_inc = 1;
          else if 46150 < hhincome <= 76850 then hud_inc = 2;
          else if 76850 < hhincome <= 97200 then hud_inc = 3;
          else if 97200 < hhincome <= 184440 then hud_inc = 4;
          else if 184440 < hhincome <= 2*(76850/0.5) then hud_inc = 5;
		  else if 2*(76850/0.5) < hhincome then hud_inc = 6;/*200% plus*/
        end;
      when ( 6 )
        do;
          if hhincome <= 49550 then hud_inc = 1;
          else if 49550 < hhincome <= 82550 then hud_inc = 2;
          else if 82550 < hhincome <= 104400 then hud_inc = 3;
          else if 104400 < hhincome <= 198120 then hud_inc = 4;
          else if 198120 < hhincome <= 2*(82550/0.5) then hud_inc = 5;
		  else if 2*(82550/0.5) < hhincome then hud_inc = 6;/*200% plus*/
        end;
      when ( 7 )
        do;
          if hhincome <= 52950 then hud_inc = 1;
          else if 52950 < hhincome <= 88250 then hud_inc = 2;
          else if 88250 < hhincome <= 111600 then hud_inc = 3;
          else if 111600 < hhincome <= 211800 then hud_inc = 4;
          else if 211800 < hhincome <= 2*(88250/0.5) then hud_inc = 5;
		  else if 2*(88250/0.5) < hhincome then hud_inc = 6; /*200% plus*/
        end;
      otherwise
        do;
          if hhincome <= 56400 then hud_inc = 1;
          else if 56400 < hhincome <= 93950 then hud_inc = 2;
          else if 93950 < hhincome <= 118800 then hud_inc = 3;
          else if 118800 < hhincome <= 225480 then hud_inc = 4;
          else if 225480 < hhincome <= 2*(93950/0.5) then hud_inc = 5;
		  else if 2*(93950/0.5) < hhincome then hud_inc = 6; /*200% plus*/
        end;
    end;

    end;

  label Hud_inc = "HUD income categories";
 

%mend Hud_inc_22_dmped;

/** End Macro Definition **/


