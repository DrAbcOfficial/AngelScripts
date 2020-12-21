open System.IO
open System.Collections.Generic
open System

module MainMod =
    let FileReader szFilepath = 
        seq { use stream = File.OpenRead szFilepath
              use reader = new StreamReader(stream)
              while not reader.EndOfStream do
              yield reader.ReadLine() }

    let Spliter szFilepath = 
        FileReader szFilepath
        |> Seq.map (fun line -> if not (line.EndsWith("=")) then line.Split ' ' else [|"0";"0"|])

    let TypeIt szFilepath = 
        let dicTemp = new Dictionary<string,int>()
        for ary in Spliter szFilepath do
            if dicTemp.ContainsKey(ary.[0]) then
                dicTemp.[ary.[0]] <- dicTemp.[ary.[0]] + int(ary.[1])
            else
                dicTemp.Add(ary.[0],int(ary.[1]))
        dicTemp

    let FileWriter szName szStr=
        use file = new StreamWriter(szName:string)
        file.Write(szStr:string)
        file.Close()

    let DicWriter szFilepath szName=
        let mutable szTemp = ""
        for KeyValue(k,v) in (TypeIt szFilepath) do
            szTemp <- szTemp + k + "," + string(v) + "\n"
        FileWriter szName szTemp
        
[<EntryPoint>]
let main argv = 
    if not (argv.Length = 0) then
        MainMod.DicWriter (argv.[0]) (Directory.GetCurrentDirectory() + "/done.txt")
    else
        printf "%s" "拖动txt到图标上运行！"
        Console.ReadKey() |> ignore
    0