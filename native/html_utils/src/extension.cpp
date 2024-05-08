#define EXTENSION_NAME html_utils
#define LIB_NAME "html_utils"
#define MODULE_NAME "html_utils"

#include <dmsdk/sdk.h>

#if defined(DM_PLATFORM_HTML5)

extern "C" void HtmlHtmlUtilsHideBg();
extern "C" bool HtmlHtmlUtilsCanvasFocus();

static int LuaHtmlUtilsHideBg(lua_State* L){
	HtmlHtmlUtilsHideBg();
    return 0;
}

static int LuaHtmlUtilsCanvasFocus(lua_State* L){
	 HtmlHtmlUtilsCanvasFocus();
    return 0;
}



static const luaL_reg Module_methods[] = {
	{"hide_bg",LuaHtmlUtilsHideBg},
	{"focus",LuaHtmlUtilsCanvasFocus},
    {0, 0}
};

static void LuaInit(lua_State* L){
	int top = lua_gettop(L);
	luaL_register(L, MODULE_NAME, Module_methods);
	lua_pop(L, 1);
	assert(top == lua_gettop(L));
}

static dmExtension::Result InitializeMyExtension(dmExtension::Params* params) {
    LuaInit(params->m_L);
    printf("Registered %s Extension\n", MODULE_NAME);
    return dmExtension::RESULT_OK;
}

#else

static dmExtension::Result InitializeMyExtension(dmExtension::Params* params) { return dmExtension::RESULT_OK;}

#endif

DM_DECLARE_EXTENSION(EXTENSION_NAME, LIB_NAME, 0, 0, InitializeMyExtension, 0, 0, 0)
