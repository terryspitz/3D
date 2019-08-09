
function reuleaux(az, theta, k) = let (
    // A torus with Reuleaux Triangle cross-section: 
    // See https://en.wikipedia.org/wiki/Reuleaux_triangle.
    //
    //Args:
    //    az: azimuth: angle sweeping round major axis.
    //    theta: [-60,60] minor axis angle sweeping round one side of triangle on minor axis.
    //    k: 0-2 side number of triangle"""
    major_radius = 12.0, // mm
    minor_radius = 3.0, // mm
    z_scale = 2, // ratio of z height to minor axis diameter
    
    cosr = cos(theta),
    rot = az*1/3,
    // Use Polar equation of a circle from https://en.wikipedia.org/wiki/Polar_coordinate_system#Circle
    // R=1, r0=1/sqrt(3) (2/3 height of unit sided equilateral triangle, offset of centre of reuleaux arc)
    r_reuleaux = (sqrt(4.0/3.0*cosr*cosr + 8.0/3.0) - 2.0/sqrt(3.0)*cosr)/2.0,
    degrees = (rot+30)%120-30,
    //echo(rot, degrees),
    r0_reuleaux = (degrees<30) ?
        1-cos(degrees)/sqrt(3.0)
        : cos(degrees-60)/sqrt(3.0),
    // or triange cross-section:
    r_triangle = 1.0/cos(theta)/6.0,
    r0_triangle = 0,

    use_reuleaux = false,
    r = use_reuleaux ? r_reuleaux : r_triangle,
    r0 = use_reuleaux ? r0_reuleaux : r0_triangle,
    
    theta2 = theta + k*120 + rot,  //twist it!
    reuleaux_factor = r * cos(theta2) - r0 - 0.5,
    //based on parametric equation of a torus
    full_radius = major_radius + minor_radius * reuleaux_factor,
    x = sin(-az) * full_radius,
    y = cos(-az) * full_radius,
    z = r * sin(theta2) * minor_radius * z_scale
    ) 
    [x, y, z];
    

az_step = 3.6;
theta_step = 10;
if(true) {
    polyhedron(points = [
        for(az = [0:az_step:360-1], k = [0:2], theta = [-60:theta_step:60-1])
            each let(
                p0 = reuleaux(az, theta, k),
                p1 = reuleaux(az+az_step, theta, k),
                p2 = reuleaux(az+az_step, theta+theta_step , k),
                p3 = reuleaux(az, theta+theta_step , k)
            ) [p0, p1, p2, p3]
        ],
        
        faces =  [for (i = [0:360/az_step*120/theta_step *3]) each
                        [[i*4,i*4+1,i*4+2], [i*4+2,i*4+3,i*4]]
        ]
    );
}
else
{
    for(az=[0:36: 360]) {
        translate([0, 0, az/36])
        polygon(points = [
            for(k = [0:2], theta = [-60:theta_step:60-1])
                each let(
                    p0 = reuleaux(az, theta, k)
                ) [[p0[1], p0[2]]]
            ]
        );
    }
}