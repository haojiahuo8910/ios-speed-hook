#import <Foundation/Foundation.h>
#include <objc/runtime.h>

// 直接在代码里声明 Substrate 函数原型，彻底解决找不到头文件的问题
extern "C" {
    void MSHookFunction(void *symbol, void *replace, void **result);
    void *MSFindSymbol(void *image, const char *name);
}

// 声明原 Unity set_timeScale 函数指针
static void (*orig_SetTimeScale)(float value);

// 自定义 Hook 拦截函数
void my_SetTimeScale(float value) {
    if (value <= 0.0f) {
        // 当游戏触发弹窗或暂停（timeScale 为 0）时，严格执行 0，彻底冻结时间
        orig_SetTimeScale(0.0f);
    } else {
        // 正常游戏时，应用你的自定义加速倍率（例如 3.0 倍）
        orig_SetTimeScale(value * 3.0f); 
    }
}

__attribute> static void initialize() {
    // 查找并 Hook Unity 的时间缩放方法
    void *sym = MSFindSymbol(NULL, "UnityEngine_Time__set_timeScale");
    if (sym) {
        MSHookFunction(sym, (void *)my_SetTimeScale, (void **)&orig_SetTimeScale);
    }
}
