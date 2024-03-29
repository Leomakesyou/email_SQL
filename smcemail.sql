USE [ComplementosHS]
GO
/****** Object:  StoredProcedure [dbo].[SP_ALERTASMCEMAIL]    Script Date: 04/15/2013 09:16:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- =============================================
-- Author:		<Leonardo Hernández>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[SP_ALERTASMCEMAIL] 
	-- Add the parameters for the stored procedure here


	@IdEvento as nvarchar (10) = null
	
	
AS
BEGIN 
SET NOCOUNT ON;

Create table #Temp (Id_del_Evento  nvarchar (MAX), Nombre_del_Evento  nvarchar (MAX), Proceso  nvarchar (MAX), Reportado_por  nvarchar (MAX), Identificacion_del_Area  nvarchar (MAX), Fecha_del_Evento  nvarchar (MAX), Descripcion_detalles_investigacion  nvarchar (MAX), Causa_Raiz nvarchar (MAX), 
ComentarioCausaRaiz  nvarchar (MAX), CausaInmediata1  nvarchar (MAX), comentarioCausaI1  nvarchar (MAX), CausaInmediata2 nvarchar (MAX), comentarioCausaI2 nvarchar (MAX), CausaInmediata3 nvarchar (MAX), comentarioCausaI3 nvarchar (MAX), Solucion nvarchar (MAX), Impacto_Personas nvarchar (MAX),
impacto_Ambiental nvarchar (MAX), Impacto_Economico nvarchar (MAX), ImpactoEnTiempo nvarchar (MAX), Responsable_Accion nvarchar (MAX), Area nvarchar (50), Origen_Evento nvarchar (50), Severidad nvarchar (50), Probabilidad nvarchar (50),
CausaBasica1 nvarchar (50), CausaBasica2 nvarchar (50), comentarioCausaB1 nvarchar (max), comentarioCausaB2 nvarchar (max), CausaFalla nvarchar (50), ResponsableProc nvarchar (200), Estado nvarchar (20), usuarioSAP nvarchar(200)) 
INSERT INTO #Temp (Id_del_Evento, Nombre_del_Evento, Proceso, Reportado_por, Identificacion_del_Area, Fecha_del_Evento, Descripcion_detalles_investigacion,Causa_Raiz, 
ComentarioCausaRaiz, CausaInmediata1, comentarioCausaI1, CausaInmediata2, comentarioCausaI2, CausaInmediata3, comentarioCausaI3, Solucion, Impacto_Personas, impacto_Ambiental, 
Impacto_Economico, ImpactoEnTiempo, Responsable_Accion, Area, Origen_Evento, Severidad, Probabilidad, CausaBasica1, CausaBasica2, comentarioCausaB1, comentarioCausaB2, CausaFalla, ResponsableProc, Estado, usuarioSAP ) EXEC ComplementosHS.dbo.SP_ALERTASMC_EMAILQUERY   @IdEvento

Create table #temp2  (CodigoLeccion  nvarchar (10), NombreLeccion  nvarchar (max), Descripcion  nvarchar (max), Causa  nvarchar (50),  Estado nvarchar (20))
INSERT INTO #Temp2 (CodigoLeccion, NombreLeccion, Descripcion, Causa, Estado) EXEC ComplementosHS.dbo.SP_ALERTASMC_LECCIONES @IdEvento

Create table #temp3 (Id nvarchar(10), Titulo_Accion nvarchar (max), Descripcion nvarchar(max), ResponsableAccion nvarchar (200), FechaObj nvarchar (20), FechaCierre nvarchar (20), Estado nvarchar (20))
INSERT INTO #temp3 (Id, Titulo_Accion, Descripcion, ResponsableAccion, FechaObj, FechaCierre, Estado) EXEC ComplementosHS.dbo.SP_ALERTASMC_ACCIONES @IdEvento

Create table #temp4 (Adjunto nvarchar (50)) INSERT INTO #Temp4 (Adjunto) EXEC ComplementosHS.dbo.SP_ALERTASMC_ADJUNTO @IdEvento

Create table #temp5  (email nvarchar (200)) INSERT INTO #Temp5 (email) EXEC ComplementosHS.dbo.SP_ALERTASMC_EMAILRESPACCIONES @IdEvento


DECLARE @AsuntoSMC NVARCHAR (255)
Set @AsuntoSMC = 'Formato SMC - Evento' + '  ' + CAST((Select Id_del_Evento from #Temp) as nvarchar(255))

DECLARE @emailreportedby varchar(max)
set @emailreportedby = (Select A0.email from LUPATECHOFSSAS.dbo.OHEM A0
						inner join LUPATECHOFSSAS.dbo.OSCL A1 on A0.EmpId = A1.Technician
						where A1.CallId =  @IdEvento)
						
DECLARE @emailboss   varchar(max)
SET @emailboss	=   (Select A0.e_mail from LUPATECHOFSSAS.dbo.OUSR A0
					inner join LUPATECHOFSSAS.dbo.OSCL A1 on A0.UserID = A1.assignee					
					where A1.CallId = @IdEvento)
						
--DECLARE @emailOwner varchar(max)
--set @emailOwner = (SELECT A0.e_mail FROM LUPATECHOFSSAS.dbo.OCRD A0
--inner join LUPATECHOFSSAS.dbo.OSCL A1 on A0.Cardcode = A1.Customer
--WHERE A1.CallId = @idevento and A0.e_mail is not null)
						
DECLARE @emailActionResp varchar(max)
set @emailActionResp = (select STUFF(
						(SELECT CAST('; ' AS varchar(MAX)) + email
							FROM #Temp5
							FOR XML PATH('')
							), 1, 1, '') as email)
							
DECLARE @emailYeferson varchar(max)
set @emailYeferson = (Select Case 
							when Proceso = 'PS-Tecnologia e Info' then 'yeferson.roncancio@hsltda.com'
							END
							from #Temp)
							
DECLARE @opendays varchar(20)
set @opendays = (Select Datediff(d,createdate,getdate()) from LUPATECHOFSSAS.dbo.OSCL
where CallID = @idEvento)	
					


DECLARE @HTMLprueba  NVARCHAR(MAX) 



Set @HTMLprueba = 




		N'<table border = "0" width = "70%">' + 
			N'<tbody align= "center">' +
				N'<tr >' + 
					N'<td style = "font-family: arial; font-size: 19px; color:#008B8B;"><b><i>Formato SMC (Sistema de Mejora Continua)</i></b></td>  
					  <td><img alt="Logo_Lupatech" src="http://www.lupatech.com.co/web/logo_lupatech_01.03.2013.png" width="200" height="60" align  = "right"></td>
				 </tr>' + N'<tr></tr><tr></tr><tr></tr><tr></tr>' +
			N'</tbody>' +
		N'</table>' + 
		N'<br></br>' +
		N'<table  width = "70%">' + 
			N'<tbody align = "center">' + 
				N'<tr>
					<td></td><td></td><td style = "font-family: arial; font-size: 15px; color:#008B8B; align: center"><b>NOMBRE DEL EVENTO</b></td>
					<td style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b>ESTADO</b></td>					
					<td style = "font-family: arial; font-size: 15px; color:#008B8B; align: center"><b>ID DEL EVENTO</b></td>
				</tr>' + 
				N'<tr>
					<td></td><td></td><td style = "font-family: arial; font-size: 15px; align: center; color: black"><b>' + CAST ((Select td = isnull(Nombre_del_Evento, 'N/A') from #temp) AS nvarchar (max)) + '</b></td>
					<td bgcolor = "#E5F0FA", style = "align: right"><b>' +  CAST ((Select td = isnull(Estado, 'N/A') from #temp) AS nvarchar (50)) +  '</b></td>					
					<td style = "font-family: arial; font-size: 15px; align: center; color: black"><b>' + CAST ((Select td = Id_del_Evento from #temp) AS nvarchar (10)) + '</b></td>
				</tr>' + 
			N'</tbody>' +
		N'</table>' +
				N'<br></br><br></br>' +
		N'<table width = "70%", cellspacing="4">' + 
			N'<tbody align = "left">' + 
		N'<tr>
			<td style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b>PROCESO</b></td>
			<td bgcolor = "#E5F0FA", style = "align: right">' +  CAST ((Select td = isnull(Proceso, 'N/A') from #temp) AS nvarchar (50)) +  '</td>
 			<td style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b>REPORTADO POR:</b></td>
 			<td bgcolor = "#E5F0FA", style = "align: right">' + CAST ((Select td = isnull(Reportado_por, 'N7A') from #temp) AS nvarchar (100)) + '</td>
		</tr>' + 
		N'<tr height = "20"> </tr>' + 
		N'<tr>
			<td  style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b>DUEÑO DEL PROCESO</b></td>
			<td colspan = "4"; bgcolor = "#E5F0FA", style = "align: right">' +  CAST ((Select td = isnull(ResponsableProc, 'N/A') from #temp) AS nvarchar (200)) +  '</td>
		</tr>' + 
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">
			<td style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b>IDENTIFICACION DEL AREA:</b></td>
			<td bgcolor = "#E5F0FA", style = "align: right">' +  CAST ((Select td = isnull(Identificacion_del_Area, 'N/A') from #temp) AS nvarchar (50)) +  '</td>
			<td style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b>JEFE - Coordinador:</b></td>
			<td bgcolor = "#E5F0FA", style = "align: right">' +  CAST ((Select td = isnull(usuarioSAP, 'N/A') from #temp) AS nvarchar (200)) +  '</td>			
		</tr>' + 
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">
			<td style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b>FECHA DEL EVENTO:</b></td>
			<td bgcolor = "#E5F0FA", style = "align: right">'  + CAST ((Select td = isnull(Fecha_del_Evento, 'N/A') from #temp) AS nvarchar (20)) + '</td>
		</tr>' + 
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">
			<td colspan = "3", style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b> DESCRIPCION DEL EVENTO Y DETALLES DE LA INVESTIGACION:</b></td>
		</tr>' + 
		N'<tr height = "20"> </tr>' +
		N'<tr align = "left">
			<td colspan = "4", bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(Descripcion_detalles_investigacion, 'N/A') from #temp) AS nvarchar (MAX)) +  '</td>
		</tr>' + 
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">
			<td style = "font-family: arial; font-size: 15px; align: left; color: #008B8B"><b>AREA:</b></td>
			<td bgcolor = "#E5F0FA", style = "align: right">' +  CAST ((Select td = isnull(Area, 'N/A') from #temp) AS nvarchar (50)) +  '</td>
		</tr>' + 
		N'<tr height = "20"> </tr>' +
		N'<tr align = "left">
			<td style = "font-family: arial; font-size: 15px; align: left; color: #008B8B"><b>ORIGEN EVENTO:</b></td>
			<td bgcolor = "#E5F0FA", style = "align: right">' +  CAST ((Select td = isnull(Origen_Evento, 'N/A') from #temp) AS nvarchar (50)) +  '</td>
		</tr>' + 
		N'<tr height = "20"> </tr>' +			
		N'<tr align = "left">
			<td style = "font-family: arial; font-size: 15px; align: left; color: #008B8B"><b>SEVERIDAD:</b></td>
			<td bgcolor = "#E5F0FA", style = "align: right">' +  CAST ((Select td = isnull(Severidad, 'N/A') from #temp) AS nvarchar (50)) +  '</td>
		</tr>' + 
		N'<tr height = "20"> </tr>' +
		N'<tr align = "left">
			<td style = "font-family: arial; font-size: 15px; align: left; color: #008B8B"><b>PROBABILIDAD:</b></td>
			<td bgcolor = "#E5F0FA", style = "align: right">' +  CAST ((Select td = isnull(probabilidad, 'N/A') from #temp) AS nvarchar (50)) +  '</td>
		</tr>' + 
		N'<tr height = "20"> </tr>' +		
		N'<tr align = "left">
			<td colspan = "3", style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b> CAUSA RAIZ:</b></td>
		</tr>' + 
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">
			<td bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(Causa_Raiz, 'N/A') from #temp) AS nvarchar (500)) +  '</td>
			<td colspan = "2", bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(ComentarioCausaRaiz, 'N/A') from #temp) AS nvarchar (500)) +  '</td>			
		</tr>' + 
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">
			<td colspan = "3", style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b> CAUSAS INMEDIATAS:</b></td>
		</tr>' + 
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">
			<td  bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(CausaInmediata1, 'N/A') from #temp) AS nvarchar (500)) +  '</td>
			<td colspan = "2", bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(comentarioCausaI1, 'N/A') from #temp) AS nvarchar (500)) +  '</td>			
		</tr>' +
		N'<tr align = "left">
			<td  bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(CausaInmediata2, 'N/A') from #temp) AS nvarchar (500)) +  '</td>
			<td colspan = "2", bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(comentarioCausaI2, 'N/A') from #temp) AS nvarchar (500)) +  '</td>			
		</tr>' +
		N'<tr align = "left">
			<td  bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(CausaInmediata3, 'N/A') from #temp) AS nvarchar (500)) +  '</td>
			<td colspan = "2", bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(comentarioCausaI3, 'N/A') from #temp) AS nvarchar (500)) +  '</td>			
		</tr>' +				 
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">
			<td colspan = "3", style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b> CAUSAS BASICAS:</b></td>
		</tr>' + 
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">
			<td  bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(CausaBasica1, 'N/A') from #temp) AS nvarchar (500)) +  '</td>
			<td colspan = "2", bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(comentarioCausaB1, 'N/A') from #temp) AS nvarchar (500)) +  '</td>			
		</tr>' +
		N'<tr align = "left">
			<td  bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(CausaBasica2, 'N/A') from #temp) AS nvarchar (500)) +  '</td>
			<td colspan = "2", bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(comentarioCausaB2, 'N/A') from #temp) AS nvarchar (500)) +  '</td>			
		</tr>' +
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">
			<td style = "font-family: arial; font-size: 15px; align: left; color: #008B8B"><b>CAUSA FALLA:</b></td>
		</tr>' +
		N'<tr align = "left">
			<td bgcolor = "#E5F0FA", style = "align: right">' +  CAST ((Select td = isnull(CausaFalla, 'N/A') from #temp) AS nvarchar (50)) +  '</td>
		</tr>' + 
		N'<tr height = "20"> </tr>' +					
		N'<tr align = "left">
			<td colspan = "3", style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b>  ACCIONES CORRECTIVAS Y/O PREVENTIVAS </b></td>
		</tr>' + 
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">' + 
			N'<td colspan = "4", align = "center", border = "0">' + 
				N'<table border = "1", cellspacing="0", bgcolor = "#E5F0FA", align = "center", width = "90%">' + 
					N'<tbody>' + 
						N'<tr bgcolor = "#008B8B">
							<th bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white; width:30">ID</th>
							<th bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white">TITULO ACCION</th>
							<th bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white">DESCRIPCION DE LA ACCION</th>
							<th bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white">RESPONSABLE DE LA ACCION</th>
							<th bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white">FECHA OBJETIVO</th>
							<th bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white">FECHA CIERRE</th>
							<th bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white">ESTADO</th>																		
						</tr>' +
						
								CAST ( ( Select 
										N'', 
										td = isnull ((ID), 'N/A'), 
										N'', 
										td = isnull ((Titulo_Accion), 'N/A'), 
										N'', 
										td = isnull ((Descripcion), 'N/A'), 
										N'', 
										td = isnull ((ResponsableAccion), 'N/A'), 
										N'', 
										td = isnull ((FechaObj), 'N/A'),
										N'',
										td = isnull ((FechaCierre), 'N/A'),
										N'',
										td = isnull ((Estado), 'N/A')
										
										FROM #temp3 FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) ) + 
			 
	
					N'</tbody>' + 
				N'</table>' + 
			N'</td>' + 
		N'</tr>'  +
		--N'<tr align = "left">
		--	<td style = "font-family: arial; font-size: 13px; align: left; color: "#E5F0FA"><i>' + CAST ((Select td = Adjunto from #temp4) AS nvarchar (100)) + '</i>
		--	</td>	
		--</tr>' +		
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">
			<td colspan = "3", style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b> LECCION APRENDIDA</b></td>
		</tr>' + 
		N'<tr height = "20"> </tr>' + 		
		N'<tr align = "left"> 
			<td colspan = "4", align = "center", border = "0">
				<table border = "1", cellspacing="0", bgcolor = "#E5F0FA", align = "center", width = "100%"> 
					<tbody>
						<tr>
							<th bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white; width:30">ID</th>
							<th bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white">RECOMENDACIONES</th>
							<th bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white">CAUSA</th>
							<th bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white">DESCRIPCION DE LA CAUSA</th>
							<th bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white">ESTADO</th>
						</tr>' + 

						
								CAST ( ( Select 
										
										N'', 
										td = isnull ((CodigoLeccion), 'N/A'),
										N'', 
										td = isnull ((NombreLeccion), 'N/A'), 
										N'', 
										td = isnull ((Causa), 'N/A'), 
										N'', 
										td = isnull ((Descripcion), 'N/A'),
										N'',
										td = isnull ((Estado), 'N/A')
									 
										FROM #temp2 FOR XML PATH('tr'), TYPE ) AS NVARCHAR(500) ) + 
					'</tbody>
				</table> 
			</td>
		</tr>' + 
		N'<tr height = "20"> </tr>' + 		
		N'<tr align = "left">
			<td colspan = "3", style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b> IMPACTOS </b></td>
		</tr>' + 
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">' + 
			N'<td colspan = "4", align = "center", border = "0">' + 
				N'<table border = "1", cellspacing="0", bgcolor = "#E5F0FA", align = "center", width = "100%">' + 
					N'<tbody>'  +
						N'<tr>
							 <td  width = "50", bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white; width:30"><b>IMPACTO PERSONA</b></td>
							 <td ,style = "font-family: arial; font-size: 15px; align: center">' + CAST ((Select td = isnull(Impacto_Personas, 'N/A') from #temp) AS nvarchar (500)) +  '</td>
						</tr>' + 
						N'<tr>
							 <td  width = "50", bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white; width:30"><b>IMPACTO AMBIENTAL</b></td>
							 <td ,style = "font-family: arial; font-size: 15px; align: center">' + CAST ((Select td = isnull(impacto_Ambiental, 'N/A') from #temp) AS nvarchar (500)) +  '</td>							
						</tr>' + 
						N'<tr>
							 <td  width = "50", bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white; width:30"><b>IMPACTO ECONOMICO</b></td>
							 <td ,style = "font-family: arial; font-size: 15px; align: center">' + CAST ((Select td = isnull(Impacto_Economico, 'N/A') from #temp) AS nvarchar (500)) +  '</td>
						</tr>' + 
						N'<tr>
							 <td  width = "50", bgcolor = "#008B8B", style = "font-family: arial; font-size: 15px; align: left; color:white; width:30"><b>IMPACTO EN EL TIEMPO</b></td>
							 <td ,style = "font-family: arial; font-size: 15px; align: center">' + CAST ((Select td = isnull(ImpactoEnTiempo, 'N/A') from #temp) AS nvarchar (500)) +  '</td>							
						</tr>' +

					N'</tbody>' + 
				N'</table>' + 
			N'</td>' + 
		N'</tr>' +
		N'<tr height = "20"> </tr>' + 
		N'<tr align = "left">
			<td colspan = "3", style = "font-family: arial; font-size: 15px; align: left; color:#008B8B"><b> SOLUCION:</b></td>
		</tr>' + 		
		N'<tr height = "20"> </tr>' +
		N'<tr align = "left">
			<td colspan = "4", bgcolor = "#E5F0FA", style = "font-family: arial; font-size: 15px; align: left">' + CAST ((Select td = isnull(Solucion, 'N/A') from #temp) AS nvarchar (MAX)) +  '</td>
		</tr>' + 
		N'<tr height = "20"> </tr>' + 	
		N'<tr height = "20"> </tr>' + 
							 
						N'<tr>
							<td colspan = "4"; style = "font-family: arial; font-size: 8px"><i> “Esta notificación ha sido enviada automáticamente, 
							por lo que responder a través de este correo electrónico no es posible. 
							Cualquier información comunicarse con el departamento de Tecnología de Información y Comunicaciones, 
							a través del correo electrónico soporte.it@hsltda.com”</i></td>
						</tr>' +
						
		N'<tr height = "20"> </tr>' 

BEGIN		

EXEC msdb.dbo.sp_send_dbmail 
	@profile_name = 'Email_system', 
	@recipients = 'leonardo.hernandez@hsltda.com',
	@copy_recipients = @emailYeferson,
	@subject = @AsuntoSMC,
    @body = @HTMLprueba,
    @body_format = 'HTML';
        
    
EXEC msdb.dbo.sp_send_dbmail 
	@profile_name = 'Email_system', 
	@recipients = @emailreportedby,
	@copy_recipients = @emailActionResp,
	@blind_copy_recipients = @emailboss,
	@subject = @AsuntoSMC,
    @body = @HTMLprueba,
    @body_format = 'HTML';
    
--EXEC msdb.dbo.sp_send_dbmail 
--	@profile_name = 'Email_system', 
--	@recipients = @emailOwner,
--	@subject = @AsuntoSMC,
--    @body = @HTMLprueba,
--    @body_format = 'HTML';
    

    

END
 
    
BEGIN       


Drop table #temp
Drop table #temp2
Drop table #temp3
Drop table #temp4
Drop table #temp5

END
END











