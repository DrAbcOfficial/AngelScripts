/**
使用此方法可以将原句柄进行包装
可以极大的避免使用传统的句柄判断方法
if (句柄 is null)
{
    balalalala
}
else
{
    balalalala
}
可节省空间，优化版面
同时因传递的都是统一接口类型，便于对句柄对象进行管理使用
(如将不同类型的句柄放入同一个数组或字典中)
因为使用该类必须将所有传递的CHandlePackage显示转换为实际类型
可以极大的避免Null Pointer Access的情况
***/

/**
    示例
**/
void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "drabc" );
	g_Module.ScriptInfo.SetContactInfo( "bruh" );
    CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity("monster_scientist", null, false);
    pEntity.pev.netname = "Foo Bar Monkey";
    CBaseEntity@ bEntity = null;
    CHandlePackage@ pPackage = CHandlePackage(pEntity);
    CHandlePackage@ bPackage = CHandlePackage(bEntity);

    g_Game.AlertMessage( at_console, "输出行[1]\n" );
    pPackage.IsNullCall(@MeNullCall, @MeCall);
    bPackage.IsNullCall(@MeNullCall, @MeCall);

    g_Game.AlertMessage( at_console, "输出行[2]\n" );
    g_Game.AlertMessage( at_console, string(pPackage.IsNull()) + "\n" );
    g_Game.AlertMessage( at_console, string(bPackage.IsNull()) + "\n" );

    g_Game.AlertMessage( at_console, "输出行[3]\n" );
    bPackage.Value = @pEntity;
    g_Game.AlertMessage( at_console, string(pPackage.IsNull()) + "\n" );
    g_Game.AlertMessage( at_console, string(bPackage.IsNull()) + "\n" );

    g_Game.AlertMessage( at_console, "输出行[4]\n" );
    g_Game.AlertMessage( at_console, string(cast<CBaseEntity>(bPackage.Get()).pev.classname) + "\n" );
}

/**
    输出结果
    输出行[1]
    I'm not a null callable, my name is Foo Bar Monkey
    I'm a null callable
    输出行[2]
    0
    1
    输出行[3]
    0
    0
    输出行[4]
    monster_scientist
**/

void MeNullCall(CHandlePackage@ obj)
{
    g_Game.AlertMessage( at_console, "I'm a null callable\n" );
}

void MeCall(CHandlePackage@ obj)
{
    g_Game.AlertMessage( at_console, "I'm not a null callable, my name is " +  string(cast<CBaseEntity@>(obj.Get()).pev.netname) + "\n");
}
/**
    示例结束
**/

funcdef void funcPackageCall(CHandlePackage@);
/**
    接口
**/
interface IHandlePackage
{
    void Set(ref@ obj);
    ref Get();
    bool IsEmpty();
    bool IsNull();
}
/**
    包装类
**/
class CHandlePackage : IHandlePackage
{
    private ref@ objHandle = null;
    private bool bEmpty = true;
    /**
        构造函数
    **/
    CHandlePackage(ref@ obj)
    {
        Set(@obj);
    }
    /**
        外露值
    **/
    ref Value
    {
        get { return objHandle;}
		set{ @objHandle = value;}
    } 
    /**
        赋值方法
    **/
    void Set(ref@ obj)
    {
        @objHandle = @obj;
        bEmpty = false;
    }
    /**
        取值方法
    **/
    ref Get()
    {
        return @objHandle;
    }
    /**
        是否已被赋值
    **/
    bool IsEmpty()
    {
        return bEmpty;
    }
    /**
        被包装值是否为空
    **/
    bool IsNull()
    {
        return @objHandle is null;
    }
    /**
        被包装值不为空则执行
        fCall 被执行的函数
    **/
    void IsNullOr(funcPackageCall@ fCall)
    {
        if(!IsNull())
            fCall(this);
    }
    /**
        被包装值为空则执行
        fCall 被执行的函数
    **/
    void IsNullThen(funcPackageCall@ fCall)
    {
        if(IsNull())
            fCall(this);
    }
    /**
        判断被包装值是否为空选择执行
        fNullCall 为空执行的函数
        fFullCall 不为空执行的函数
    **/
    void IsNullCall(funcPackageCall@ fNullCall = null, funcPackageCall@ fFullCall = null)
    {
        if(fNullCall !is null)
            IsNullThen(fNullCall);
        if(fFullCall !is null)
            IsNullOr(fFullCall);
    }
}
