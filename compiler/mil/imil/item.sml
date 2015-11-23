(* The Haskell Research Compiler *)
(* COPYRIGHT_NOTICE_1 *)

signature IMIL_ITEM = 
sig
  include IMIL_PUBLIC_TYPES

  val getUses   : t * item -> use Vector.t
  val getUsedBy : t * item -> item Vector.t
  val freeVars  : t * item -> Identifier.VariableSet.t
  val freeVars' : t * item -> Mil.variable list
  val delete    : t * item -> unit

  val toIInstr  : item -> iInstr option
  val toIGlobal : item -> iGlobal option
  val toIFunc   : item -> iFunc option

  val toInstruction : item -> Mil.instruction option
  val toRhs         : item -> Mil.rhs option
  val toTransfer    : item -> Mil.transfer option
  val toLabel       : item -> (Mil.label * Mil.variable vector) option
  val toGlobal      : item -> (Mil.variable * Mil.global) option

  val fx : t * item -> Effect.set

  val splitUses' : t * item * use Vector.t -> {inits : use Vector.t, others : use Vector.t}
  val splitUses  : t * item  -> {inits : use Vector.t, others : use Vector.t}

  val layout    : t * item -> Layout.t
  val print     : t * item -> unit
end

structure IMilItem : 
sig
  include IMIL_ITEM
  val itemGetId : item -> int
end
  = 
struct
  open IMilPublicTypes

  structure IMT = IMilTypes
  structure Global = IMilGlobal
  structure Instr = IMilInstr
  structure Func = IMilFunc 

  datatype item = datatype IMT.item
                           
  val itemGetId =
   fn i => 
      case i
       of ItemInstr i  => IMT.iInstrGetId i
        | ItemGlobal g => IMT.iGlobalGetId g
        | ItemFunc c => IMT.iFuncGetId c

  val getId =
   fn (p, i) => itemGetId i

  val getUses =
   fn (p, i) => 
      case i
       of ItemInstr i  => Instr.getUses (p, i)
        | ItemGlobal g => Global.getUses (p, g)
        | ItemFunc c => Func.getUses (p, c)

  val getUsedBy =
   fn (p, i) => 
      let
        val items = 
            case i
             of ItemInstr i  => Instr.getUsedBy (p, i)
              | ItemGlobal g => Global.getUsedBy (p, g)
              | ItemFunc c => Func.getUsedBy (p, c)
                           
      in items
      end

  local
    val gen =
     fn (fi, gi, ci) => 
     fn (p, i) => 
        let
          val items = 
              case i
               of ItemInstr i  => fi (p, i)
                | ItemGlobal g => gi (p, g)
                | ItemFunc c   => ci (p, c)
                               
        in items
        end
  in 
  val freeVars  = gen (Instr.freeVars,  Global.freeVars,  Func.freeVars)
  val freeVars' = gen (Instr.freeVars', Global.freeVars', Func.freeVars')
  end

  val delete =
   fn (p, i) => 
      case i
       of ItemInstr i  => Instr.delete (p, i)
        | ItemGlobal g => Global.delete (p, g)
        | ItemFunc c   => Func.delete (p, c)

  val toIInstr  = IMT.itemToIInstr
  val toIGlobal = IMT.itemToIGlobal
  val toIFunc   = IMT.itemToIFunc

  val toInstruction = Utils.Option.compose (IMT.iInstrToInstruction, toIInstr)
  val toRhs         = Utils.Option.compose (IMT.iInstrToRhs, toIInstr)
  val toTransfer    = Utils.Option.compose (IMT.iInstrToTransfer, toIInstr)
  val toLabel       = Utils.Option.compose (IMT.iInstrToLabel, toIInstr)
  val toGlobal      = Utils.Option.compose (IMT.iGlobalToGlobal, toIGlobal)

  val fx = 
   fn (imil, i) =>
      (case i
        of IMT.ItemInstr i  => Instr.fx (imil, i)
         | IMT.ItemGlobal g => Effect.Total
         | IMT.ItemFunc c   => Effect.Total)

  val splitUses' = 
   fn (t, i, us) => 
      (case toIInstr i
        of SOME i => Instr.splitUses' (t, i, us)
         | NONE => {inits = Vector.new0(), others = us})

  val splitUses =
   fn (t, i) => splitUses' (t, i, getUses (t, i))

  val layout =
   fn (imil, i) => IMilLayout.item (imil, i)

  val print = LayoutUtils.printLayout o layout

end
