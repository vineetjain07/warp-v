\m4_TLV_version 1d: tl-x.org
\SV

   // =========================================
   // Welcome!  Try the tutorials via the menu.
   // =========================================

   // Default Makerchip TL-Verilog Code Template
   
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)

\TLV
   $reset = *reset;

   m4_define(['EXPWIDTH'],['8'])
   m4_define(['SIGWIDTH'],['24'])
   m4_define(['NORMDISTWIDTH'],\$clog2(SIGWIDTH))
   
   |pipe
      @1
         //`BOGUS_USE($in[32:0])
         $in[32:0] = 33'h1a5464eb1;

         $minNormExp[EXPWIDTH : 0] = (1 << (EXPWIDTH - 1)) + 2;

         { $sign,$exp[EXPWIDTH:0],$fract[(SIGWIDTH - 2):0] } = $in;         
         $isSpecial = (($exp >> (EXPWIDTH - 1)) == 2'b11);
         $isNaN = $isSpecial && $exp[EXPWIDTH - 2];
         $isInf = $isSpecial && (! $exp[EXPWIDTH - 2]);
         $isZero = (($exp >> (EXPWIDTH - 2)) == 3'b000);
         $sexp[(EXPWIDTH + 1 ):0] = $exp;
         $sig[SIGWIDTH : 0] = {1'b0, {! $isZero}, $fract};         
         
         $isSubnormal = ($sexp < $minNormExp);
         
         $denormShiftDist[(NORMDISTWIDTH - 1):0] = $minNormExp - 1 - $sexp;
         $expOut[(EXPWIDTH - 1):0] =
            ($isSubnormal ? 0 : $sexp - $minNormExp + 1)
            | ($isNaN || $isInf ? {EXPWIDTH{1'b1}} : 0);
         $fractOut[(SIGWIDTH - 2):0] =
             $isSubnormal ? ($sig >> 1) >> $denormShiftDist : $isInf ? 0 : $sig;
         $out[(EXPWIDTH + SIGWIDTH - 1):0] = {$sign, $expOut, $fractOut};

   // Assert these to end simulation (before Makerchip cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
