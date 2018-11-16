drop table message_box;
CREATE TABLE message_box(
    message     VARCHAR(200),
    log_time    TIMESTAMP
);

drop procedure ins_msg_proc;
CREATE PROCEDURE ins_msg_proc (p_msg VARCHAR(200)) LANGUAGE SQLSCRIPT AS
BEGIN
    INSERT INTO message_box VALUES (:p_msg, CURRENT_TIMESTAMP);
END;

drop procedure init_proc;
CREATE PROCEDURE init_proc LANGUAGE SQLSCRIPT AS
BEGIN
    DELETE FROM message_box;
END;

/* ***************************************** */

DROP TABLE TYPE tt_merged_trace;
CREATE TABLE TYPE tt_merged_trace (
	"HOST" VARCHAR(256),
	"PORT" BIGINT,
	"SERVICE_NAME" VARCHAR(256),
	"THREAD_ID" BIGINT,
	"TIMESTAMP" TIMESTAMP,
	"TRACE_LEVEL" VARCHAR(8),
	"COMPONENT" VARCHAR(32),
	"SOURCE_FILE_NAME" VARCHAR(512),
	"SOURCE_FILE_LINE" BIGINT,
	"TRACE_TEXT" NCLOB);

DROP TABLE TYPE tt_merged_trace_bar;
CREATE TABLE TYPE tt_merged_trace_bar ("POS" INTEGER, "TIMESTAMP" TIMESTAMP, "SEVERITY" INTEGER);

/* ***************************************** */

DROP PROCEDURE getMergedTraceLevelLLang;
CREATE PROCEDURE getMergedTraceLevelLLang 
(
	IN mergedTrace tt_merged_trace, 
	IN chunks INTEGER, 
	OUT mergedTraceBar tt_merged_trace_bar
)
LANGUAGE LLANG
READS SQL DATA
AS
BEGIN
	typedef Table<String "HOST", Fixed8<0> "PORT", String "SERVICE_NAME", Fixed8<0> "THREAD_ID", Timestamp "TIMESTAMP", String "TRACE_LEVEL", String "COMPONENT", String "SOURCE_FILE_NAME", Fixed8<0> "SOURCE_FILE_LINE", String "TRACE_TEXT"> T_MERGED_TRACE;
	typedef Table<Int32 "POS", Timestamp "TIMESTAMP", Int32 "SEVERITY"> T_MERGED_TRACE_BAR;

	Int32 getSeverity(String traceLevel) {
		Int32 severity = 0;
		if (traceLevel == "Error") {
			severity = 3; 
		} else if (traceLevel == "Warning") {
			severity = 2; 
		} else if (traceLevel == "Info") {
			severity = 1; 
		} else if (traceLevel == "Alert") {
			severity = 4; 
		}
		return severity; 
	}
	
	export Void main(
  		T_MERGED_TRACE mergedTrace,
  		Int32 chunks,
  		T_MERGED_TRACE_BAR & mergedTraceBar)
	{
		Column<String> colTraceLevel = mergedTrace.getColumn<String>("TRACE_LEVEL");
		Column<Timestamp> colTimestamp1 = mergedTrace.getColumn<Timestamp>("TIMESTAMP");

		Column<Int32> colPos = mergedTraceBar.getColumn<Int32>("POS");
		Column<Int32> colSeverity = mergedTraceBar.getColumn<Int32>("SEVERITY");
		Column<Timestamp> colTimestamp2 = mergedTraceBar.getColumn<Timestamp>("TIMESTAMP");
	
		Size maxRows = mergedTrace.getSize();

		Int32 severity = 0;
		Int32 severityMax = 0;
		
		Int32 chunkSize = Int32(maxRows) / chunks;
		Int32 chunkCount = 0;
		
		Size row = 0z;
		Size rowChunk = 0z;
		
		while (row < maxRows) {
			if (chunkCount == 0) {
				colPos[rowChunk] = Int32(rowChunk);
				colTimestamp2[rowChunk] = colTimestamp1[row];
			}
			
			severity = getSeverity(colTraceLevel[row]);
			
			if (severity > severityMax) {
				severityMax = severity;
			} 
			
			row = row.next();
			
			chunkCount = chunkCount + 1;
			
			if (chunkCount == chunkSize) {
				colSeverity[rowChunk] = severityMax;
				
				rowChunk = rowChunk.next();
				chunkCount = 0;
				severityMax = 0;
			}
		}
		
		if (chunkCount > 0) {
			colSeverity[rowChunk] = severityMax;
		}
	}
END;

DROP PROCEDURE getMergedTraceLevel;
CREATE PROCEDURE getMergedTraceLevel 
(
	IN mergedTrace tt_merged_trace, 
	IN chunks INTEGER, 
	OUT mergedTraceBar tt_merged_trace_bar
)
LANGUAGE SQLSCRIPT AS
BEGIN
	init_proc();
    ins_msg_proc('chunks ' || :chunks);
    
	DATA_SORTED = SELECT * FROM :mergedTrace ORDER BY "TIMESTAMP" ASC;
		
	CALL getMergedTraceLevelLLang(:DATA_SORTED, :chunks, :mergedTraceBar);
END;

