# Physical constants

This library enables to use fundamental physical constants (speed of light in vacuum, Planck constant ... and isotopic
masses). Several versions can be selected:

- **CODATA 2006**: (default), downloaded from `NIST <http://physics.nist.gov/cuu/Constants/archive2006.html>`. 
- **CODATA 2014**: downloaded from `NIST <https://physics.nist.gov/cuu/Constants/archive2014.html>`.
- **CODATA 2018**: downloaded from `NIST <https://physics.nist.gov/cuu/Constants/index.html>` (acces 29/01/2023).
- **Handbook 70ED**: Constants and masses from the 70th edition of the Handbook of Chemistry and Physics.

Furthermore, several version of atomic isotopic masses can be selected:

- and the NIST
  `masses <https://www.nist.gov/pml/atomic-weights-and-isotopic-compositions-relative-atomic-masses>` downloaded in
  2012.



From these fundamental constants, some conversion factors are calculated automatically and can be used easily.

Remark: the actual mass values of the NIST web page differ slightly from the module ones.
General quantum dynamics code using curvilinear coordinates:


## 1) &constantes namelist

This namelist can be used without parameter, it enables to change energy unit and selects different version of physical constants atomic version or to redefine some of them.

Most of the quantities (energy, time, length, angle...) can be read with an unit. Then, they are converted to the working unit (atomic unit).

The following parameters can be used in this namelist:

* **version** (default **"CODATA2006"**): The value **"CODATA2006"** enables to use physical constants defined in codata2006. The other possibilities are: **"CODATA2014"**, **"HANDBOOK70ED"** (70ed of the Physical chemistry Handbook) and **"PUBLI2001"** (modification of 70ed of the Physical chemistry Handbook). The default is used when the "version" is not correct.

* **mass_version** (default **"NIST2012"**): The value **"NIST2012"** enables to use masses published by the NIST in 2012. The other possibilities are: **"NIST2018"**, **"HANDBOOK70ED"** (70ed of the Physical chemistry Handbook). The default is used when the "mass_version" is not correct.


* **ene_unit** (default **"cm-1"**): This value stores the name of the printed energy unit and it enables to select some energy conversion (see **auTOenergy**). If the value of **ene_unit** is different from the ones in following list, a personal unit is used and **ene_unit** is just the name of this new unit. The conversion from atomic unit to the personal the unit is selected with **auTOenergy** parameter. The possible values are of **ene_unit** are:

    * **"cm-1"**: wave number unit (default).
    * **"au"** or **"hartree"**: atomic unit or Hartree unit (the working energy unit).
    * **"ev"** or **"eV"**: electron volt unit.
    * **"GHz"**: energy expressed as GHz.
    * **"°K"**: energy expressed as Kelvin.
    * **"kcal.mol-1"**
    * **"kJ.mol-1"**

* **auTOenergy**: This parameter enables to change the printed energy unit conversion.


* **PhysConst_path** (default **compilation directory**): it enables to read the isotopic masses and the physical constants (CODOTA ones) from an internal file.
This parameter can be changed in the &constantes namelist.

The following parameters can be use to modify some physical constants (to reproduce calculations with wrong ones).

* **auTOcm_inv** : This parameter enables to modify energy conversion factor to **"cm-1"**. It has an effect only if **ene_unit="cm-1"**.
* **inv_Name** : This parameter enables to modify mass conversion factor (au <=> g.mol-1).