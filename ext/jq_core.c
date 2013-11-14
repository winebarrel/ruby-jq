#include "jq_core.h"

static VALUE rb_eJQ_Error;

static void rb_jq_free(struct jq_container *p) {
  xfree(p);
}

static VALUE rb_jq_alloc(VALUE klass) {
  struct jq_container *p;
  p = ALLOC(struct jq_container);
  p->jq = NULL;
  p->closed = 1;
  return Data_Wrap_Struct(klass, 0, rb_jq_free, p);
}

static VALUE rb_jq_initialize(VALUE self, VALUE program) {
  struct jq_container *p;
  jq_state *jq;
  int compiled;

  Data_Get_Struct(self, struct jq_container, p);
  Check_Type(program, T_STRING);
  jq = jq_init();

  if (jq == NULL) {
    rb_raise(rb_eJQ_Error, "%s", strerror(errno));
  }

  compiled = jq_compile(jq, RSTRING_PTR(program));

  if (!compiled) {
    jq_teardown(&jq);
    rb_raise(rb_eJQ_Error, "compile error");
  }

  p->jq = jq;
  p->closed = 0;

  return Qnil;
}

static VALUE rb_jq_close(VALUE self) {
  struct jq_container *p;
  Data_Get_Struct(self, struct jq_container, p);

  if (!p->closed) {
    jq_teardown(&p->jq);
    p->closed = 1;
  }

  return Qnil;
}

static void jq_process(jq_state *jq, jv value, VALUE (*proc)(), int *status) {
  jq_start(jq, value, 0);
  jv result;

  while (jv_is_valid(result = jq_next(jq)) && *status == 0) {
    jv dumped = jv_dump_string(result, 0);
    const char *str = jv_string_value(dumped);
    rb_protect(proc, rb_str_new2(str), status);
  }

  jv_free(result);
}

static void jq_parse(jq_state *jq, char *buf, int is_partial, VALUE (*proc)()) {
  struct jv_parser* parser = jv_parser_new();
  jv value;
  int status = 0, error = 0;
  VALUE errmsg;

  jv_parser_set_buf(parser, buf, strlen(buf), is_partial);

  while (jv_is_valid((value = jv_parser_next(parser))) && status == 0) {
    jq_process(jq, value, proc, &status);
  }

  if (jv_invalid_has_msg(jv_copy(value))) {
    jv msg = jv_invalid_get_msg(value);
    error = 1;
    errmsg = rb_str_new2(jv_string_value(msg));
    jv_free(msg);
  } else {
    jv_free(value);
  }

  jv_parser_free(parser);

  if (status != 0) {
    rb_jump_tag(status);
  }

  if (error) {
    rb_raise(rb_eJQ_Error, "%s", RSTRING_PTR(errmsg));
  }
}

static VALUE rb_jq_update(VALUE self, VALUE buf, VALUE is_partial) {
  struct jq_container *p;

  if (!rb_block_given_p()) {
    rb_raise(rb_eArgError, "no block given");
  }

  Data_Get_Struct(self, struct jq_container, p);
  Check_Type(buf, T_STRING);
  jq_parse(p->jq, RSTRING_PTR(buf), is_partial ? 1 : 0, rb_yield);

  return Qnil;
}

void Init_jq_core() {
  VALUE rb_mJQ = rb_define_module("JQ");
  VALUE rb_cJQ_Core = rb_define_class_under(rb_mJQ, "Core", rb_cObject);
  rb_eJQ_Error = rb_define_class_under(rb_mJQ, "Error", rb_eStandardError);
  rb_define_alloc_func(rb_cJQ_Core, rb_jq_alloc);
  rb_define_private_method(rb_cJQ_Core, "initialize", rb_jq_initialize, 1);
  rb_define_method(rb_cJQ_Core, "close", rb_jq_close, 0);
  rb_define_method(rb_cJQ_Core, "update", rb_jq_update, 2);
}
