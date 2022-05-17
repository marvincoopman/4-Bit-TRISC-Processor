module TermProject(
	input startStop, SysClock, ClockIn, ClearAddGen, RW, Mode,

	input [7:0] DataIn,
	output [5:0]a, b, c, d, e, f, g,
	output[8:0] Datadisplay,
	output [14:0] displayControlBus
);

	wire [7:0] MDO, MDI; //MDO 7:4 opcode
	wire [3:0] PCout;
	
	wire [14:0] ControlBus; 
	
	wire[3:0]  ALUtoBUFFER, AddressBus, IRtoCU, BRtoACC;
	
	wire [3:0]      AddIn, AddGen, RAMadd; 
	wire RAMin, RAMwrite, toggle; 
	wire [7:0]      RAMdata;
	
	assign RAMadd = ControlBus[3] == 1'b0 ? MDO[3:0] : PCout;
	assign ALUin = MDI[3:0];
	
	assign Datadisplay[7:0] = DataIn;
	assign Datadisplay[8] = Mode;
	assign AddIn = Mode == 1'b0 ? RAMadd : AddressBus; 
	assign RAMin = Mode == 1'b0 ? SysClock*ControlBus[4]: ClockIn; 
	assign RAMdata = Mode == 1'b0 ? MDI : DataIn; 
	assign RAMwrite = Mode == 1'b0 ? ControlBus[5] : ~RW; 
	assign displayControlBus = ControlBus;
	

	
	NbitBinaryCounter ProgramCounter (.CNT(~ControlBus[2]),
	.CLR(~ControlBus[0]),
	.LOAD(~ControlBus[1]),
	.A(MDO[3:0]),.Y(PCout)); //PC
	
	NbitParallelInOut InstructionRegister (.Clock(~ControlBus[7]),
	.Clear(startStop),
	.D(MDO[7:4]),
	.Q(IRtoCU));  // IR
	
	NbitParallelInOut BufferRegister (.Clock(~ControlBus[14]),
	.Clear(startStop),.D(ALUtoBUFFER),
	.Q(BRtoACC));  // BR
	
	FourBitAccumulator Accumulator(.A(MDO[3:0]), 
	.B(BRtoACC), .LOAD(~ControlBus[11]), 
	.CLR(~ControlBus[8]), .CNT(~ControlBus[9]), 
	.AorB(ControlBus[10]), .Z(MDI[3:0])); //ACC
	
	ALU ALU(.A(MDI[3:0]), .B(MDO[3:0]), .state(ControlBus[13:12]),
	.R(ALUtoBUFFER)); //ALU
	
	ProcessorControlUnit ControlUnit(.SysClock(SysClock), .StartStop(startStop), .x(MDO[7:4]), 
	.C0(ControlBus[0]), .C1(ControlBus[1]), .C2(ControlBus[2]), .C3(ControlBus[3]),
	.C4(ControlBus[4]), .C5(ControlBus[5]),.C7(ControlBus[7]), .C8(ControlBus[8]),
	.C9(ControlBus[9]), .C10(ControlBus[10]), .C11(ControlBus[11]),
	.C12(ControlBus[12]), .C13(ControlBus[13]),  .C14(ControlBus[14])); //CONTROL UNIT
	
	

	OnOffToggle DivideX2 
	( 
		.OnOff(ClockIn) ,   // input  OnOff_sig 
		.IN(1'b1) ,    // input  IN_sig 
		.OUT(toggle)     // output  OUT_sig 
	); 
	BinUp AddressGen 
	( 
		.inc(toggle) ,    // input  inc_sig 
		.clear(ClearAddGen) ,   // input  clear_sig 
		.load(1'b1) ,    // input  load_sig 
		.D(4'b0) ,    // input  [N-1:0] D_sig 
		.Q(AddressBus)     // output [N-1:0] Q_sig 
	); 
	triscRAM RAM 
	( 
		.address ( AddIn ), 
		.clock ( ~RAMin ), 
		.data ( RAMdata ), 
		.wren ( RAMwrite ), 
		.q ( MDO ) 
	); 
	
	binary2seven displayMDILSB (.w(RAMdata[3]),.x(RAMdata[2]),.y(RAMdata[1]),.z(RAMdata[0]),.a(a[0]),.b(b[0]),.c(c[0]),.d(d[0]),.e(e[0]),.f(f[0]),.g(g[0]));
	binary2seven displayMDIMSB (.w(RAMdata[7]),.x(RAMdata[6]),.y(RAMdata[5]),.z(RAMdata[4]),.a(a[1]),.b(b[1]),.c(c[1]),.d(d[1]),.e(e[1]),.f(f[1]),.g(g[1]));
	binary2seven displayMDOLSB (.w(MDO[3]),.x(MDO[2]),.y(MDO[1]),.z(MDO[0]),.a(a[2]),.b(b[2]),.c(c[2]),.d(d[2]),.e(e[2]),.f(f[2]),.g(g[2]));
	binary2seven displayMDOMSB (.w(MDO[7]),.x(MDO[6]),.y(MDO[5]),.z(MDO[4]),.a(a[3]),.b(b[3]),.c(c[3]),.d(d[3]),.e(e[3]),.f(f[3]),.g(g[3]));
	binary2seven displayMAR    (.w(AddIn[3]),.x(AddIn[2]),.y(AddIn[1]),.z(AddIn[0]),.a(a[4]),.b(b[4]),.c(c[4]),.d(d[4]),.e(e[4]),.f(f[4]),.g(g[4]));
	binary2seven displayPC     (.w(PCout[3]),.x(PCout[2]),.y(PCout[1]),.z(PCout[0]),.a(a[5]),.b(b[5]),.c(c[5]),.d(d[5]),.e(e[5]),.f(f[5]),.g(g[5]));


	
	
	

endmodule 