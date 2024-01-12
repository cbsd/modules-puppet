# A strict type for group blocks
type Csync2::GroupBlock = Struct[{
    includes           => Array[String],
    Optional[excludes] => Array[String],
    Optional[actions]  => Array[Csync2::GroupBlockAction],
}]
