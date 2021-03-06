USE [SA_SAP_NL]
GO
/****** Object:  Table [Import].[QALS]    Script Date: 16-Jun-22 9:21:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Import].[QALS]') AND type in (N'U'))
BEGIN
CREATE TABLE [Import].[QALS](
	[Inspection Lot] [varchar](256) NULL,
	[Version] [varchar](256) NULL,
	[Plant] [varchar](256) NULL,
	[Long text] [varchar](256) NULL,
	[Update group (stats)] [varchar](256) NULL,
	[Inspection Type] [varchar](256) NULL,
	[Insp lot origin] [varchar](256) NULL,
	[Object number] [varchar](256) NULL,
	[Object Category] [varchar](256) NULL,
	[Status Profile] [varchar](256) NULL,
	[QM material auth ] [varchar](256) NULL,
	[GR blocked stock] [varchar](256) NULL,
	[Inspection stock] [varchar](256) NULL,
	[Insp  lot created] [varchar](256) NULL,
	[Partial lots exist] [varchar](256) NULL,
	[Id  record modified] [varchar](256) NULL,
	[Individual QM order] [varchar](256) NULL,
	[Insp  during prod ] [varchar](256) NULL,
	[Automatic UD] [varchar](256) NULL,
	[Source inspection] [varchar](256) NULL,
	[Insp  by configuratn] [varchar](256) NULL,
	[Short-term insp ] [varchar](256) NULL,
	[Inspect by batch] [varchar](256) NULL,
	[InsLot creation] [varchar](256) NULL,
	[Docu  required] [varchar](256) NULL,
	[Insp  plan required] [varchar](256) NULL,
	[Manual sample] [varchar](256) NULL,
	[Insp  with mat spec ] [varchar](256) NULL,
	[Approval insp  lot] [varchar](256) NULL,
	[Dig  signature in results recording] [varchar](256) NULL,
	[Dig  signature at usage decision] [varchar](256) NULL,
	[Dig  signature phys -samp  drwng conf] [varchar](256) NULL,
	[Appr batch rec  req ] [varchar](256) NULL,
	[R 2 inspection lot] [varchar](256) NULL,
	[Man  char  selection] [varchar](256) NULL,
	[Man  sample calc ] [varchar](256) NULL,
	[StckPostings compl ] [varchar](256) NULL,
	[Usage decision made] [varchar](256) NULL,
	[Dynam  material] [varchar](256) NULL,
	[Dynam  vendor] [varchar](256) NULL,
	[Dynam manufacturer] [varchar](256) NULL,
	[Dynam  customer] [varchar](256) NULL,
	[Dyn  machine] [varchar](256) NULL,
	[Dynam  project] [varchar](256) NULL,
	[Skip] [varchar](256) NULL,
	[Skips allowed] [varchar](256) NULL,
	[100% inspection] [varchar](256) NULL,
	[Serial numbers poss ] [varchar](256) NULL,
	[No serial numbers] [varchar](256) NULL,
	[Dynamic modification] [varchar](256) NULL,
	[Dynamic mod  level] [varchar](256) NULL,
	[Sampling procedure] [varchar](256) NULL,
	[Ext  numbering] [varchar](256) NULL,
	[Origin of Inspection Lot Unit of Measure] [varchar](256) NULL,
	[QINF Status] [varchar](256) NULL,
	[Lot created on] [varchar](256) NULL,
	[Lot created at] [varchar](256) NULL,
	[Created by] [varchar](256) NULL,
	[Created on] [varchar](256) NULL,
	[Lot created at (2)] [varchar](256) NULL,
	[Changed by] [varchar](256) NULL,
	[Changed on] [varchar](256) NULL,
	[Lot changed at ] [varchar](256) NULL,
	[Insp  start date] [varchar](256) NULL,
	[Inspection start at ] [varchar](256) NULL,
	[End of Inspection] [varchar](256) NULL,
	[Inspection ended at ] [varchar](256) NULL,
	[Task List Type] [varchar](256) NULL,
	[Group] [varchar](256) NULL,
	[Usage (2)] [varchar](256) NULL,
	[Group Counter] [varchar](256) NULL,
	[Counter] [varchar](256) NULL,
	[Add  crit  counter] [varchar](256) NULL,
	[Production Resource Tool Saved for Insp ] [varchar](256) NULL,
	[User field combinat ] [varchar](256) NULL,
	[Insp  point type] [varchar](256) NULL,
	[Partial-lot assign ] [varchar](256) NULL,
	[Counter (2)] [varchar](256) NULL,
	[Sample-drawing proc ] [varchar](256) NULL,
	[Confirmation req ] [varchar](256) NULL,
	[Material] [varchar](256) NULL,
	[Revision Level] [varchar](256) NULL,
	[Plant (2)] [varchar](256) NULL,
	[Vendor] [varchar](256) NULL,
	[ManufPartNo active] [varchar](256) NULL,
	[Manufacturer] [varchar](256) NULL,
	[Customer] [varchar](256) NULL,
	[Usage] [varchar](256) NULL,
	[Key date] [varchar](256) NULL,
	[Order] [varchar](256) NULL,
	[Routing number for operations] [varchar](256) NULL,
	[Internal object no ] [varchar](256) NULL,
	[Internal object no (2)] [varchar](256) NULL,
	[Production Version] [varchar](256) NULL,
	[Run schedule header] [varchar](256) NULL,
	[Customer (2)] [varchar](256) NULL,
	[Vendor (2)] [varchar](256) NULL,
	[Manufacturer (2)] [varchar](256) NULL,
	[MPN Material] [varchar](256) NULL,
	[Material (2)] [varchar](256) NULL,
	[Revision Level (2)] [varchar](256) NULL,
	[Batch management] [varchar](256) NULL,
	[Batch] [varchar](256) NULL,
	[Storage Location] [varchar](256) NULL,
	[Valid to] [varchar](256) NULL,
	[SLED BBD] [varchar](256) NULL,
	[Vendor Batch] [varchar](256) NULL,
	[Special Stock] [varchar](256) NULL,
	[WBS Element] [varchar](256) NULL,
	[Sales Order] [varchar](256) NULL,
	[Sales order item] [varchar](256) NULL,
	[Purch  Organization] [varchar](256) NULL,
	[Purchasing Document] [varchar](256) NULL,
	[Item] [varchar](256) NULL,
	[Schedule Line] [varchar](256) NULL,
	[Document Type] [varchar](256) NULL,
	[Material Doc  Year] [varchar](256) NULL,
	[Material Document] [varchar](256) NULL,
	[Material Doc Item] [varchar](256) NULL,
	[Posting Date] [varchar](256) NULL,
	[Movement Type] [varchar](256) NULL,
	[Plant InspLotStock] [varchar](256) NULL,
	[StorLoc InspLotStock] [varchar](256) NULL,
	[Warehouse Number] [varchar](256) NULL,
	[Storage Type] [varchar](256) NULL,
	[Storage Bin] [varchar](256) NULL,
	[Sales Order (2)] [varchar](256) NULL,
	[Delivery] [varchar](256) NULL,
	[Item (2)] [varchar](256) NULL,
	[Delivery category] [varchar](256) NULL,
	[Route] [varchar](256) NULL,
	[Destination Country] [varchar](256) NULL,
	[Sold-to party] [varchar](256) NULL,
	[Sales Organization] [varchar](256) NULL,
	[Customer material number] [varchar](256) NULL,
	[Language Key] [varchar](256) NULL,
	[Short text] [varchar](256) NULL,
	[Short text for inspection object] [varchar](256) NULL,
	[Charac  recorded] [varchar](256) NULL,
	[Short-term charac ] [varchar](256) NULL,
	[Long-term charac ] [varchar](256) NULL,
	[Insp  Lot Quantity] [varchar](256) NULL,
	[Base unit of measure] [varchar](256) NULL,
	[Number of Containers] [varchar](256) NULL,
	[Lot container] [varchar](256) NULL,
	[Ind insp sample WM] [varchar](256) NULL,
	[WM sample quantity] [varchar](256) NULL,
	[Sample size] [varchar](256) NULL,
	[Sample unit of meas ] [varchar](256) NULL,
	[Modification rule] [varchar](256) NULL,
	[Time of dyn  modif ] [varchar](256) NULL,
	[Inspection stage] [varchar](256) NULL,
	[Inspection severity] [varchar](256) NULL,
	[Unrestricted-Use Stock] [varchar](256) NULL,
	[Scrap quantity] [varchar](256) NULL,
	[Sample] [varchar](256) NULL,
	[Blocked stock] [varchar](256) NULL,
	[Reserves] [varchar](256) NULL,
	[New material] [varchar](256) NULL,
	[Material (3)] [varchar](256) NULL,
	[Batch (2)] [varchar](256) NULL,
	[Return to vendor] [varchar](256) NULL,
	[Other quantity] [varchar](256) NULL,
	[Other quantity 2] [varchar](256) NULL,
	[Quantity to be posted] [varchar](256) NULL,
	[Long-term sample qty] [varchar](256) NULL,
	[Inspected quantity] [varchar](256) NULL,
	[Destroyed quantity] [varchar](256) NULL,
	[Actual lot quantity] [varchar](256) NULL,
	[Defect  qty in IQty] [varchar](256) NULL,
	[Inspection lot logs] [varchar](256) NULL,
	[Share of scrap] [varchar](256) NULL,
	[Q-Score Procedure] [varchar](256) NULL,
	[UD mode] [varchar](256) NULL,
	[Allowed scrap share] [varchar](256) NULL,
	[QM Order] [varchar](256) NULL,
	[Consumption] [varchar](256) NULL,
	[Acct Assignment Cat ] [varchar](256) NULL,
	[Item Category] [varchar](256) NULL,
	[AccAss  key] [varchar](256) NULL,
	[Cost Center] [varchar](256) NULL,
	[Item No Stock Transfer Reserv ] [varchar](256) NULL,
	[Asset] [varchar](256) NULL,
	[Subnumber] [varchar](256) NULL,
	[WBS Element (2)] [varchar](256) NULL,
	[Network] [varchar](256) NULL,
	[Counter (3)] [varchar](256) NULL,
	[Sales Order (3)] [varchar](256) NULL,
	[Sales Order Item (2)] [varchar](256) NULL,
	[Real Estate Key] [varchar](256) NULL,
	[Reference Date] [varchar](256) NULL,
	[Cost Object] [varchar](256) NULL,
	[Profitab  Segmt No ] [varchar](256) NULL,
	[Profit Center] [varchar](256) NULL,
	[Business Area] [varchar](256) NULL,
	[G L Account] [varchar](256) NULL,
	[Controlling Area] [varchar](256) NULL,
	[Company Code] [varchar](256) NULL,
	[Serial no  profile] [varchar](256) NULL,
	[Reference insp  lot] [varchar](256) NULL,
	[Empty] [varchar](256) NULL,
	[Insp  lot stability study] [varchar](256) NULL,
	[Indicator  Multiple Specifications] [varchar](256) NULL,
	[Dummy] [varchar](256) NULL,
	[Dummy (2)] [varchar](256) NULL,
	[Dummy (3)] [varchar](256) NULL,
	[Dummy (4)] [varchar](256) NULL,
	[Dummy (5)] [varchar](256) NULL,
	[Dummy (6)] [varchar](256) NULL,
	[Dummy (7)] [varchar](256) NULL,
	[Dummy (9)] [varchar](256) NULL,
	[Dummy (10)] [varchar](256) NULL,
	[Dummy (11)] [varchar](256) NULL,
	[Dummy (12)] [varchar](256) NULL,
	[Dummy (13)] [varchar](256) NULL,
	[Dummy (14)] [varchar](256) NULL,
	[Dummy (15)] [varchar](256) NULL,
	[Dummy (16)] [varchar](256) NULL,
	[Dummy Field (No Function)] [varchar](256) NULL,
	[Maintenance Plan] [varchar](256) NULL,
	[Maintenance item] [varchar](256) NULL,
	[MntPlan Call No ] [varchar](256) NULL,
	[Maintenance strategy] [varchar](256) NULL,
	[Trial Number] [varchar](256) NULL,
	[Responsible] [varchar](256) NULL,
	[Insp  Document No ] [varchar](256) NULL,
	[Logical system] [varchar](256) NULL,
	[Size of Sample] [varchar](256) NULL,
	[Sample unit of meas  (2)] [varchar](256) NULL,
	[Priority Points] [varchar](256) NULL,
	[Signature Type R R ] [varchar](256) NULL,
	[Signature Type U D ] [varchar](256) NULL,
	[Signature Type P-SD] [varchar](256) NULL,
	[SignatureStrategy RR] [varchar](256) NULL,
	[SignatureStrategy UD] [varchar](256) NULL,
	[SignatureStrat  P-SD] [varchar](256) NULL,
	[Sales Order Item (3)] [varchar](256) NULL,
	[RecordSource] [varchar](255) NULL,
	[InsertedDateTime] [datetime] NULL
) ON [PRIMARY]
END
GO
