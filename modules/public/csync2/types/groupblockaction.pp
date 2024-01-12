# A strict type for group block actions
type Csync2::GroupBlockAction = Struct[{
    pattern           => Array[String],
    exec              => Array[String],
    Optional[logfile] => Stdlib::Absolutepath,
    Optional[do]      => Enum['do-local', 'do-local-only'],
}]
