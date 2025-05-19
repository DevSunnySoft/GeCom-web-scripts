CREATE TABLE public.activity_logs
(
    _id uuid NOT NULL,
    entity character varying NOT NULL,
    operation_type character varying NOT NULL,
    record_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL, 
    changed_by uuid,
    PRIMARY KEY (_id)
);

ALTER TABLE IF EXISTS public.activity_logs
    OWNER to postgres;

CREATE INDEX idx_activity_logs_created_at
    ON public.activity_logs USING btree
    (created_at DESC NULLS LAST)
    WITH (deduplicate_items=True)
;


INSERT INTO public.versions values (gen_random_uuid(), CURRENT_TIMESTAMP, null, 12, '0.12');