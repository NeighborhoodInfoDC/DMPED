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

%macro Hud_inc_22_dmped( hhinc=, hhsize= );

  ** HUD income categories (<year>) **;

  if (&hhinc.) in ( 9999999, .n ) then hud_inc = .n;
  else do;

           select ( numprec );
      when ( 1 )
        do;
          if &hhinc. <= 29900 then hud_inc = 1;
          else if 29900 < &hhinc. <= 49850 then hud_inc = 2;
          else if 49850 < &hhinc. <= 63000 then hud_inc = 3;
          else if 63000 < &hhinc. <= 119640 then hud_inc = 4;
          else if 119640 < &hhinc. <= 2*(49850/0.5)then hud_inc = 5;
		  else if 2*(49850/0.5) < &hhinc. then hud_inc = 6;/*200% plus*/
        end;
      when ( 2 )
        do;
          if &hhinc. <= 34200 then hud_inc = 1;
          else if 34200 < &hhinc. <= 56950 then hud_inc = 2;
          else if 56950 < &hhinc. <= 72000 then hud_inc = 3;
          else if 72000 < &hhinc. <= 136680 then hud_inc = 4;
          else if 136680 < &hhinc. <= 2*(56950/0.5) then hud_inc = 5;
		  else if 2*(56950/0.5) < &hhinc. then hud_inc = 6;/*200% plus*/
        end;
      when ( 3 )
        do;
          if &hhinc. <= 38450 then hud_inc = 1;
          else if 38450 < &hhinc. <= 64050 then hud_inc = 2;
          else if 64050 < &hhinc. <= 81000 then hud_inc = 3;
          else if 81000 < &hhinc. <= 153720 then hud_inc = 4;
          else if 153720 < &hhinc. <= 2*(64050/0.5) then hud_inc = 5;
		  else if 2*(64050/0.5) < &hhinc. then hud_inc = 6;/*200% plus*/
        end;
      when ( 4 )
        do;
          if &hhinc. <= 42700 then hud_inc = 1;
          else if 42700 < &hhinc. <= 71150 then hud_inc = 2;
          else if 71150 < &hhinc. <= 90000 then hud_inc = 3;
          else if 90000 < &hhinc. <= 170760 then hud_inc = 4;
          else if 170760 < &hhinc. <= 2*(71150/0.5) then hud_inc = 5;
		  else if 2*(71150/0.5) < &hhinc. then hud_inc = 6;/*200% plus*/
        end;
      when ( 5 )
        do;
          if &hhinc. <= 46150 then hud_inc = 1;
          else if 46150 < &hhinc. <= 76850 then hud_inc = 2;
          else if 76850 < &hhinc. <= 97200 then hud_inc = 3;
          else if 97200 < &hhinc. <= 184440 then hud_inc = 4;
          else if 184440 < &hhinc. <= 2*(76850/0.5) then hud_inc = 5;
		  else if 2*(76850/0.5) < &hhinc. then hud_inc = 6;/*200% plus*/
        end;
      when ( 6 )
        do;
          if &hhinc. <= 49550 then hud_inc = 1;
          else if 49550 < &hhinc. <= 82550 then hud_inc = 2;
          else if 82550 < &hhinc. <= 104400 then hud_inc = 3;
          else if 104400 < &hhinc. <= 198120 then hud_inc = 4;
          else if 198120 < &hhinc. <= 2*(82550/0.5) then hud_inc = 5;
		  else if 2*(82550/0.5) < &hhinc. then hud_inc = 6;/*200% plus*/
        end;
      when ( 7 )
        do;
          if &hhinc. <= 52950 then hud_inc = 1;
          else if 52950 < &hhinc. <= 88250 then hud_inc = 2;
          else if 88250 < &hhinc. <= 111600 then hud_inc = 3;
          else if 111600 < &hhinc. <= 211800 then hud_inc = 4;
          else if 211800 < &hhinc. <= 2*(88250/0.5) then hud_inc = 5;
		  else if 2*(88250/0.5) < &hhinc. then hud_inc = 6; /*200% plus*/
        end;
      otherwise
        do;
          if &hhinc. <= 56400 then hud_inc = 1;
          else if 56400 < &hhinc. <= 93950 then hud_inc = 2;
          else if 93950 < &hhinc. <= 118800 then hud_inc = 3;
          else if 118800 < &hhinc. <= 225480 then hud_inc = 4;
          else if 225480 < &hhinc. <= 2*(93950/0.5) then hud_inc = 5;
		  else if 2*(93950/0.5) < &hhinc. then hud_inc = 6; /*200% plus*/
        end;
    end;

    end;

  label Hud_inc = "HUD income categories";
 

%mend Hud_inc_22_dmped;

/** End Macro Definition **/


